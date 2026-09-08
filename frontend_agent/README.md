# `gds_agent`

A third surface for `gds_env`. Headless. Agent-shaped. Opinionated about
plumbing so you don't have to be.

> **This describes what is built, not what was planned.** It was `SPEC.md`
> until audit 2.6 and drifted from the code in six places, because a spec is
> written once and a README is expected to keep up. Where this file and the
> code disagree, **the code wins** — the authoritative sources are
> `frontend_agent/opencode.json` (providers, models, LSPs),
> `frontend_agent/Dockerfile` (what is installed), and `utils/gdsa` (mounts,
> env, subcommands). Anything enumerated here that lives in one of those
> files is a summary with a date on it, not a second source of truth.

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
  warts. We don't fork them — and we deliberately **don't pin** them either:
  `frontend_agent/Dockerfile` carries a `CACHEBUST` arg precisely so every
  build reinstalls the latest harnesses. That is the repo-wide policy (audit
  4.1), not an oversight. It also means a rebuild can change harness
  behaviour under you; that is the trade.
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

### opencode: AI provider wiring

**Two providers, both self-hosted, both via `@ai-sdk/openai-compatible`. No
cloud provider is configured.**

| Provider | Endpoint env | What it is |
|---|---|---|
| `ollama` | `OLLAMA_HOST` | An Ollama server. The original wiring, mirrored from Sancho. |
| `openai` | `OPENAI_HOST` | Any OpenAI-compatible server — vLLM, llama.cpp, and friends. Added in PR #117. Independent of `OLLAMA_HOST`; it may point at a different machine. |

The image ships a default `opencode.json` at
`/home/jovyan/.config/opencode/opencode.json` declaring:

- Both providers, each with its `baseURL` built at runtime from its endpoint
  env var — `http://{env:OLLAMA_HOST}/v1` and `http://{env:OPENAI_HOST}/v1`.
  The env vars stay bare `host:port` (Ollama's own convention); the scheme and
  `/v1` are added in the template, since the OpenAI-compatible SDK needs a
  real, parseable URL
- The models each provider may serve, every one with `tool_call: true`
- The LSP block above

**The model list is not reproduced here.** It churns — three PRs changed it
in the two months to 2026-09 — and a copy in prose is a copy that goes stale.
`opencode.json` is the list; `frontend_agent/skills/opencode-models/SKILL.md`
is the procedure for changing it, including how to resolve a loose name
against what the server actually has. The top-level `model` key sets the
launch default and must name a model declared under one of the providers.

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
| `gdsa update` | Replace this launcher with a fresh copy from `master` (preserving a symlinked install) |
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
| `~/.config/gh/` | same | rw | `claude`, `opencode` and `copilot` — all three shell out to `gh` |

Per-harness config dirs only mount for the relevant subcommand — running
`gdsa claude` won't expose your opencode tokens, and `gdsa shell` mounts
none of the harness creds at all.

The host config dir still only mounts when it exists. The install step
now creates it and seeds it from the baked defaults, so the mounted
behavior matches the image defaults unless you edit those host files.

### Env passthrough

Explicit allowlist, and it is **per-subcommand** — each harness sees only
what it needs. Forwarded only when set on the host:

| Subcommand | Forwarded from host |
|---|---|
| `gdsa claude` | `ANTHROPIC_API_KEY`, `GITHUB_TOKEN`, `GH_TOKEN` |
| `gdsa copilot` | `GITHUB_TOKEN`, `GH_TOKEN`, `COPILOT_*` |
| `gdsa opencode` | `OLLAMA_HOST` (resolved, see below), `OPENAI_HOST` (if set) |
| `gdsa shell` | nothing |

`gdsa opencode` also sets `GLAMOUR_STYLE` and, when a host config is in play,
`OPENCODE_CONFIG_CONTENT` — those are set *by* the launcher, not passed
through from your environment.

Nothing else. Want more, ask for it. No `*_KEY` globbing, no full env
dump. Your secrets stay where you put them.

Note `OPENAI_API_KEY` is **not** forwarded. Both providers are self-hosted
and neither needs it; `frontend_agent/compose.yml` still accepts it, which is
a difference worth knowing if you use compose rather than the launcher.

### Ollama wiring (`gdsa opencode` only)

1. **Endpoint**: `$OLLAMA_HOST` wins if set. Otherwise read
   `provider-url.txt` next to the launcher. Otherwise fail loud with a
   sentence telling you what to do. Expected format is bare `host:port`,
   no scheme — same as Ollama's own CLI/server env var convention.
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

No `--safe` mode. If you want prompts, run the harness directly inside
`gdsa shell`.

## Repo layout

```
frontend_agent/
  Dockerfile            # ARG base_image, layered on gds:latest
  compose.yml           # reference compose for purists
  opencode.json         # baked default: LSPs + both providers + models
  tui.json              # opencode TUI theme
  claude-settings.json  # baked Claude Code settings
  README.md             # this file
  skills/               # skills authored here; see skills/README.md
  # notebook-cli skill is fetched from upstream at build time
utils/
  gdsa                  # the launcher
Makefile                # build_agent + install_gdsa targets
```

## Deliberately not included

Each of these is a decision, not a gap:

- Pre-installed MCP servers (install per-project, like a normal person)
- Jupyter/code-server in this image (wrong surface — use the other two)
- CI release workflow (local builds only; `image_build.yml` covers the base
  `gds` image and is manual)
- Auto-detecting the harness from cwd (be explicit)
- Docker socket / nested docker (no)
- Strict permission mode (the container is the sandbox)
- Cloud providers for opencode — both configured providers are self-hosted

## Loose ends

- **Harness "skip approval" flags** are unpinned by policy, so they can change
  under a rebuild. If a harness starts prompting, check its flag against the
  table under *Permission posture* first.
- **`OPENAI_API_KEY`** is accepted by `compose.yml` but forwarded by neither
  `gdsa` nor either provider. Harmless, but it means the two entry points do
  not take exactly the same environment.
