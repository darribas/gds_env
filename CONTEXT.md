# CONTEXT.md — briefing for remediation sessions

You are working in `darribas/gds_env` on **one finding** from `FABLE_AUDIT.md` (repo root).
Read this file first, then read your assigned finding (e.g. "2.3") in the audit —
it contains the diagnosis, the **Proposed fix**, and the validation expected. Everything
here is background so you don't have to rediscover it.

## What this repository is

`gds_env` builds a family of Docker images for Geographic Data Science, used for
teaching and research. Python + R live in one conda environment (`gds`) on top of the
Jupyter docker-stacks base. Four images:

| Image | Built from | Purpose |
|---|---|---|
| `gds` | `env/Dockerfile` + `env/installers/*.sh` | Main image: JupyterLab + conda env + CLI tools |
| `gds_code` | `frontend_code/Dockerfile` (on top of `gds`) | code-server (VS Code in browser) |
| `gds_agent` | `frontend_agent/Dockerfile` (on top of `gds`) | Headless agent harnesses (Claude Code, opencode, Copilot) |
| Binder shim | root `Dockerfile` (2 lines) | Binder entrypoint; do not confuse with the main build |

## Map

```
env/Dockerfile            The main build. Calls scripts from env/installers/ in sequence.
env/installers/*.sh       One tool per script. Run inside Dockerfile layers.
env/gds_amd64.yml         Conda spec (amd64).  ── These two are a hand-mirrored pair;
env/gds_arm64.yml         Conda spec (arm64).  ── any package change touches BOTH.
env/{py,r,dev}/           Check notebooks (used by `make test`) + generated stack listings.
Makefile                  build / test / website targets. Recipes are TABS, /bin/bash.
utils/gdsa                Host-side launcher for gds_agent (bash).
frontend_agent/SPEC.md    Design doc for gds_agent (known to drift from implementation).
website/                  Jekyll SOURCE.   docs/ is BUILT OUTPUT — never edit docs/ by hand.
docker/*.md               Guides + release_checklist.md (the release process of record).
.github/workflows/        build_site.yml works; the three test_* workflows are broken (audit 2.1).
```

## Facts that will save you from mistakes

- **Two conda envs by design** (audit 4.5): the Lab *server* + labextensions live in the
  **base** env; the `gds` env is a *kernel* + user toolchain. `env/Dockerfile:26` prepends
  `/opt/conda/envs/gds/bin` to PATH. Don't "simplify" one into the other.
- **User/paths**: user is `jovyan` (UID 1000), `$HOME=/home/jovyan` — and `$HOME` stays
  `/home/jovyan` even in `USER root` Dockerfile steps. Installers run as root unless the
  Dockerfile says otherwise; files they write into `$HOME` need `fix-permissions`.
- **Layer hygiene rule**: any cleanup (`rm`, `apt-get clean`, `fix-permissions`) only
  saves space if it runs in the SAME `RUN` as the install that created the files.
- **`ARG BUILDARCH`** is auto-populated by BuildKit; it selects `gds_$BUILDARCH.yml`.
- **Generated files — don't hand-edit**: `docs/` (from `website/`), `website/_includes/`
  (from README/CONTRIBUTING/docker guides via `make website_build`),
  `env/{py,r}/stack_*` listings (via `make write_stacks`).
- **Versioning**: dev builds use `GDS_ENV_VERSION` (currently `11.0alpha` in
  `env/Dockerfile`); releases are tagged `darribas/gds:<version>` per
  `docker/release_checklist.md`. Version strings are (for now) written in several files —
  see audit 2.2/3.9 before touching any of them.
- Findings cross-reference each other (e.g. 2.1↔3.2, 3.3↔4.3, 1.9↔2.1, 3.5↔2.10).
  Your finding's text names its dependencies — read those sections too, but **implement
  only your assigned item** unless the audit explicitly says to fold items together.

## Build & verify

- `make build` — builds `gds` (image tag `gds:<date>_<arch>` + `gds:latest`). **Takes
  hours** and downloads ~GBs; only run it when your finding's validation requires it.
- `make test` / `make test_py` / `make test_r` / `make test_dev` — execute the check
  notebooks in `env/{py,r,dev}/` against `$(image)` (default `gds:<today>_<arch>`; pass
  `image=...`). Logs land in `env/test_*.log`.
- `make build_code image=...` / `make build_agent image=...` — the frontend images.
- Cheap checks that need no build: `docker run --rm <img> <cmd>` against an existing
  image, `shellcheck` on any script you touch, `python -c "import yaml; yaml.safe_load(open(...))"`
  for the specs, rendering the Makefile with `make -n <target>`.
- If Docker or a long build is unavailable in your session, do the change anyway,
  run whatever static checks you can, and **state exactly which validation remains**
  in your commit/PR message. Never claim a verification you didn't run.

## Working rules

1. One finding per session/branch. Branch from `master` unless told otherwise; name it
   after the finding (e.g. `audit/2.3-env-lang`).
2. Match the repo's existing style (e.g. the `apt-get update && install --no-install-recommends
   && rm -rf /var/lib/apt/lists/*` pattern; plain `#---  ---#` comment banners).
3. The audit's **Proposed fix is the spec**. If reality on the ground contradicts it
   (file moved, already fixed, line numbers drifted — they reference commit `1c5282a`),
   trust the repo, say so in your summary, and adapt rather than forcing the edit.
4. Some findings need a maintainer decision first (3.6, 4.4b, and all of plan tier 3).
   If your finding's fix says "maintainer call" and you have no decision in your prompt,
   stop and ask instead of choosing.
5. Don't fix unrelated problems you notice — note them in your summary instead.
6. Commit messages: short imperative subject, body says what was validated and how.
   Reference the finding number (e.g. "audit 2.3").

## Definition of done

- The change matches the finding's Proposed fix (or documents why it deviates).
- Validation named in the finding was run, with results reported honestly.
- No generated files hand-edited; both arch ymls updated if either was.
- Summary states: what changed, what was verified, what (if anything) is left for the
  maintainer (settings changes, long rebuilds, decisions).
