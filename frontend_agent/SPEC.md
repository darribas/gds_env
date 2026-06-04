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

The image also ships the `notebook-cli` skill at the opencode skills
path, **fetched from upstream `jupyter-ai-contrib/nb-cli` at build
time** (not vendored). Every fresh build pulls whatever's at HEAD of
the upstream `skills/notebook-cli/` tree — SKILL.md plus any
`references/*` it picks up — so the agent always sees the maintainer's
current guidance.

User customization wins: if you bind-mount your own
`~/.config/opencode/` from the host, your config replaces the baked one
wholesale. If you don't, the baked one runs the show. The installer now
bootstraps `~/.config/opencode/` with copies of the baked
`opencode.json` and `tui.json` when they're missing, so persistence can
work out of the box without changing defaults.

## The launcher (`gdsa`)

POSIX bash. Lives in `utils/gdsa`. `make build_agent` symlinks it to
`~/.local/bin/gdsa` for you — and on macOS, amends `~/.zshrc` or
`~/.bash_profile` if `~/.local/bin` isn't already on PATH. Idempotent;
won't duplicate the PATH stanza on subsequent runs. Override the
install location with `GDSA_BIN=/somewhere/else/gdsa make install_gdsa`.
That install step also creates `~/.local/share/opencode/` and
`~/.config/opencode/` if missing, and seeds the host opencode config
with the repo defaults when those files are absent.

No Python, no Go, no Node on the host. You already have bash and
docker; that's the contract.

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
| `~/.local/share/opencode/`, `~/.config/opencode/` | same | rw | `opencode` only; `make install_gdsa` / `make build_agent` bootstrap them if missing |
| `~/.copilot/` | same | rw | `copilot` only |
| `~/.config/gh/` | same | rw | `copilot` only |

Per-harness config dirs only mount for the relevant subcommand — running
`gdsa claude` won't expose your opencode tokens, and `gdsa shell` mounts
none of the harness creds at all.

The host config dir still only mounts when it exists. The install step
now creates it and seeds it from the baked defaults, so the mounted
behavior matches the image defaults unless you edit those host files.

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

### Preflight diagnostics

Before launching, `gdsa` audits the host for the files it's about to
bind-mount and warns (never blocks) when something's missing:

- `~/.gitconfig` missing → warn with the `git config --global` snippet
- `~/.ssh/` missing → warn that SSH-based git push won't work + `ssh-keygen` snippet
- Harness auth dir missing (`~/.claude.json`, `~/.copilot/`, etc.) → warn that first run will trigger the harness's own login flow, and tell you where it'll persist after
- `gh` auth missing when invoking `copilot` → suggest running `gh auth login` in the environment launching `gdsa`

Warnings are yellow when stdout is a TTY, plain text otherwise. The
launcher always proceeds to `docker run` — the diagnostics are setup
guidance, not gatekeeping.

### Permission posture

Permissive by default. The container *is* the sandbox. The launcher
passes each harness's "skip approval" flag:

- Claude Code: `--dangerously-skip-permissions`
- Copilot CLI: `--allow-all`
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
  SPEC.md             # agent-surface spec
  # notebook-cli skill is fetched from upstream at build time
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
