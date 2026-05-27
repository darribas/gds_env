# `gds_agent` — SPEC

A third surface for `gds_env`. Headless. Agent-shaped. Opinionated about
plumbing so you don't have to be.

## What this is

A Docker image (`gds_agent`) that takes the base `gds` image and bolts on
the harnesses people actually use to drive agents — **Claude Code CLI**,
**opencode**, **GitHub Copilot CLI** — plus the tools those agents reach
for when nobody gives them any (ripgrep, fd, fzf, jq, gh, jupyter, `nb`).

And a thin host-side launcher, `gdsa`, that runs the thing without making
you remember a `docker run` command longer than your arm.

## What this is not

- A new IDE. Use `gds_code` if you want code-server.
- A jupyter server. Use the base image if you want lab.
- A research project. The harnesses ship as-is, with their own flags and
  warts. We pin versions, we don't fork.
- An auth manager. Auth happens on your host. We bind-mount the relevant
  config dirs so an ephemeral container doesn't ask you to log in every
  five minutes.

## The image

| | |
|---|---|
| **Name** | `gds_agent` |
| **Tags** | `<DATE>_<ARCH>` and `latest`, matching the rest of the family |
| **Base** | `gds:latest` from `env/`. Not the legacy `gds_py` — that's dead. |
| **Mode** | Headless. No jupyter, no code-server. The container is a CLI runtime; the harness is the UI. |
| **Arch** | `amd64` and `arm64`. Both, day one. |
| **User / workdir** | `jovyan` (UID 1000) / `/home/jovyan/work`. Same as the rest of the family. |

### What's in the box

| Category | Stuff |
|---|---|
| Agent harnesses | Claude Code CLI, opencode, GitHub Copilot CLI |
| Search/filter | ripgrep, fd, fzf, jq |
| GitHub | `gh` |
| Notebooks | `nb` (jupyter-ai-contrib/nb-cli), papermill, jupytext, nbconvert |
| LSPs | pyright, bash-language-server, yaml-language-server, vscode-langservers-extracted (json + markdown), typescript-language-server, dockerfile-language-server, r-languageserver |

LSPs sit on PATH and get auto-wired into opencode via the baked
`opencode.json`. Claude Code and Copilot CLI don't care about LSPs; that's
fine — they're on PATH for any future harness that does.

### opencode: AI provider wiring (mirrored from Sancho)

Ollama-only. Via `@ai-sdk/openai-compatible`. No cloud fallback.

The image ships a default `opencode.json` at
`/home/jovyan/.config/opencode/opencode.json` declaring:

- `ollama` provider, `baseURL` pulled from `OLLAMA_HOST` at runtime
- Two models, both with `tool_call: true`:
  - `qwen3.5:35b-a3b-coding-nvfp4`
  - `gemma4:26b-64k`
- The LSP block above

The image also ships a `notebook-cli` skill at the opencode skills path
telling the agent to prefer `nb` for `.ipynb` work. Sancho-identical.

User customization wins: if you bind-mount your own
`~/.config/opencode/` from the host, your config replaces the baked one
wholesale. If you don't, the baked one runs the show.

## The launcher (`gdsa`)

POSIX bash. Lives in `utils/gdsa`. Drop it on your PATH (or use the
provided one-liner installer), done. No Python, no Go, no Node on the
host. You already have bash and docker; that's the contract.

### Subcommands

| Command | What it does |
|---|---|
| `gdsa claude [path]` | Claude Code in `path` (default `$PWD`), permissive |
| `gdsa opencode [path]` | opencode in `path`, Ollama-wired, with keep-alive |
| `gdsa copilot [path]` | Copilot CLI in `path`, permissive |
| `gdsa shell [path]` | Interactive bash in `path`. No harness. No credentials mounted. |
| `gdsa update` | Replace this launcher with a fresh copy from `main` |
| `gdsa help` | Print usage |

### Mounts (per invocation)

| Host | Container | Mode | When |
|---|---|---|---|
| `$path` | `/home/jovyan/work` | rw | always |
| `~/.gitconfig` | same | ro | always (if exists) |
| `~/.ssh/` | same | ro | always (if exists) |
| `~/.claude/`, `~/.claude.json` | same | rw | `claude` only |
| `~/.local/share/opencode/`, `~/.config/opencode/` | same | rw | `opencode` only, **only if exists on host** |
| `~/.config/github-copilot/` | same | rw | `copilot` only |
| `~/.config/gh/` | same | rw | `copilot` only |

Per-harness config dirs only mount for the relevant subcommand — running
`gdsa claude` won't expose your opencode tokens, and `gdsa shell` mounts
none of the harness creds at all.

The "only if exists" rule on opencode's config dir is deliberate: it lets
the image's baked `opencode.json` stay in charge until you decide to
override it on the host.

### Env passthrough

Explicit allowlist. Forwarded to the container only when set on host:

- `ANTHROPIC_API_KEY`, `OPENAI_API_KEY`
- `GITHUB_TOKEN`, `GH_TOKEN`
- `COPILOT_*`
- `OLLAMA_HOST` (opencode subcommand only)

Nothing else. Want more, ask for it. No `*_KEY` globbing, no full env
dump. Your secrets stay where you put them.

### Ollama wiring (`gdsa opencode` only)

1. **Endpoint**: `$OLLAMA_HOST` wins if set. Otherwise read
   `provider-url.txt` next to the launcher. Otherwise fail loud with a
   sentence telling you what to do.
2. **DNS pin**: extract the hostname, resolve it via
   `getent`/`dscacheutil`/`dig`/`host` (Tailscale MagicDNS friendly),
   pass `--add-host hostname:ip` so the container resolves the same IP
   the host does even on a host-only network.
3. **Keep-alive**: background loop, every 4 minutes, reads the active
   model from opencode's state file and POSTs a keep-alive ping to
   Ollama with a 5-minute window. `trap`-cleaned on container exit so
   it doesn't leak. Lifted from Sancho's `run.sh`.

### Permission posture

Permissive by default. The container *is* the sandbox. The launcher
passes each harness's "skip approval" flag:

- Claude Code: `--dangerously-skip-permissions`
- Copilot CLI: `--allow-all-tools`
- opencode: no flag — opencode runs without per-action prompts by default

No `--safe` mode in v1. If you want prompts, run the harness directly
inside `gdsa shell`.

## Repo layout

```
frontend_agent/
  Dockerfile          # ARG base_image, layered on gds:latest
  compose.yml         # reference compose for purists
  opencode.json       # baked default: LSPs + Ollama provider
  tui.json            # opencode TUI theme
  skills/
    notebook-cli/
      SKILL.md        # tells opencode to use `nb` for .ipynb
utils/
  gdsa                # the launcher
Makefile              # gains build_agent target
```

## Out of scope for v1

- Pre-installed MCP servers (install per-project, like a normal person)
- Jupyter/code-server in this image (wrong surface)
- CI release workflow (local builds only)
- Auto-detecting harness from cwd (be explicit)
- Docker socket / nested docker (no)
- Strict permission mode (the container is the sandbox)
- Cloud providers for opencode (Sancho mirror — Ollama only)

## Known TBDs (resolve during implementation)

- Exact "skip approval" flag per harness — verify against pinned
  versions at build time. Update the launcher when they drift.
- `gdsa update` source — pinned to `main` of `darribas/gds_env` raw URL
  for v1. Add a flag to pin to a tag later.
