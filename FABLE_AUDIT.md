# `gds_env` repository audit

**Date:** 2026-07-07 · **Scope:** full repository at commit `1c5282a` · **Status:** report only — no changes applied

This document reviews the repository across four axes: (1) efficiencies, particularly the footprint of the final Docker images; (2) contradictions in the code and docs; (3) duplication and opportunities to streamline; and (4) other improvements. Each finding cites file and line so it can be actioned independently. A prioritised summary closes the report.

---

## Executive summary — the ten highest-value items

| # | Finding | Where | Impact |
|---|---------|-------|--------|
| 1 | `fix-permissions $CONDA_DIR` and all cleanup run in **separate layers**, so deletions save nothing and the permissions pass likely *duplicates the multi-GB conda tree* in a new layer | `env/Dockerfile:71-90` | Very large image-size win |
| 2 | Three of four GitHub workflows are **dead** — they reference a `gds_py/` directory deleted in the June 2024 reorg | `.github/workflows/test_python_environment_*.yml`, `test_windows_installer.yml` | CI is silently broken; release checklist relies on it |
| 3 | 11 of 13 installer scripts have **no `set -e`**, and several end in cleanup commands that mask failures — a failed `mamba env create` can still produce a "successful" build | `env/installers/*.sh` | Silent build corruption |
| 4 | The image ships (at least) **two Chromium copies** (pyppeteer + DeckTape's puppeteer/playwright) plus X11 `-dev` header packages it doesn't need at runtime | `env/installers/install_conda_env.sh`, `install_decktape.sh` | ~300–500 MB |
| 5 | `ENV LANG="C.UTF-8 LC_ALL=C.UTF-8"` sets one broken variable instead of two | `env/Dockerfile:11` | Locale misconfigured in every image |
| 6 | `gds_amd64.yml` and `gds_arm64.yml` are a **214-line near-duplicate pair** maintained by hand-commenting; they have already drifted (pins, missing packages) | `env/gds_*.yml` | Maintenance burden + real drift |
| 7 | `Makefile` `docker run` lacks `--rm` — every `make test` leaves three exited containers (each holding a copy of the image's writable layer) | `Makefile:3` | Host disk creep |
| 8 | Version/naming drift: `.gitpod.yml` pins `darribas/gds_dev:7.0` (four majors old, dead image name); `env/*/README.md` still describe the retired `gds_py`/`gds_dev` flavour architecture | `.gitpod.yml`, `env/{py,r,dev}/README.md` | User-facing confusion |
| 9 | `install_r_extra.sh` begins with `et -e` (typo for `set -e`); the script is disabled in the Dockerfile but kept, and its reason for existing (`tmap` v4 not on conda) is contradicted by `r-tmap>=4` now being in the yml | `env/installers/install_r_extra.sh:2`, `env/Dockerfile:29`, `env/gds_amd64.yml:144` | Dead, broken code |
| 10 | Almost all third-party tool downloads are unpinned (`latest` releases, `curl \| bash`, `@latest` npm/npx), so builds are non-reproducible and supply-chain-exposed | installers, `frontend_agent/Dockerfile`, `frontend_code/Dockerfile` | Reproducibility/security |

---

## 1. Efficiencies (image footprint and build cost)

### 1.1 Layering defeats every cleanup pass — the single biggest size issue

In Docker's overlay filesystem, a layer can only *add* bytes; deleting or modifying files created in an earlier layer stores whiteouts/copies without shrinking anything. `env/Dockerfile` runs all of its cleanup in layers *after* the installs:

- `env/Dockerfile:71-72` — `RUN fix-permissions $HOME && fix-permissions $CONDA_DIR` as a standalone layer. `fix-permissions` chgrps/chmods every file it touches; on overlayfs each metadata change triggers a copy-up of the file into the new layer. Run against `$CONDA_DIR` after the ~500-package environment is installed, this can **duplicate the entire conda tree (multiple GB) into one extra layer**. The upstream jupyter docker-stacks always call `fix-permissions` inside the same `RUN` as the install for exactly this reason.
- `env/Dockerfile:74-82` — `rm -rf` of gem caches, apt lists and `$HOME/scripts`, plus `apt-get autoclean/autoremove/clean`, in their own layer: zero size reduction, only new whiteout entries.
- `env/Dockerfile:86-90` — `find /opt/conda … -name '*.a'/-name '*.pyc' -delete && pip cache purge` in yet another layer: same problem, and it is a duplicate of the identical pass already done (correctly, in-layer) by `install_conda_env.sh:11-15`.
- `env/Dockerfile:46-47` — the `htop` layer runs `apt-get update` but never removes `/var/lib/apt/lists/*`; the lists (~50 MB+) are baked into that layer and the "cleanup" at line 78-81 cannot remove them.

**Recommendation:** make each `RUN` self-cleaning (install → configure → clean → `fix-permissions` in one layer), drop the standalone cleanup layers, and consider `docker build --squash`-style flattening or a final multi-stage `COPY --from` only if further compaction is needed. Fixing 1.1 alone will likely shrink the published image more than every other item combined. The `utils/size_explorer.ipynb` notebook can verify before/after.

### 1.2 Multiple embedded browsers

- `install_conda_env.sh:8` runs `pyppeteer-install`, downloading a standalone Chromium (~150–180 MB) for `pyppeteer` (pinned in `env/gds_amd64.yml:69`), used by jupyter-book's PDF export. Note pyppeteer is unmaintained upstream.
- `install_decktape.sh` downloads a second Chromium via puppeteer (amd64) or `npx playwright@latest` (arm64) into `/opt/decktape-browser`.

Two headless Chromium installs do the same job. Point pyppeteer at the DeckTape browser (`PYPPETEER_EXECUTABLE_PATH` honoured via jupyter-book config, or symlink into pyppeteer's expected cache path), or migrate PDF export to the playwright-based tooling and keep exactly one browser. Saves ~150–200 MB.

### 1.3 DeckTape's apt list includes build-time `-dev` packages

`install_decktape.sh:39-52` installs `libcairo2-dev`, `libasound2-dev`, `libx11-xcb-dev`, `libxcursor-dev`, `libxdamage-dev`, `libxi-dev`, `libxtst-dev`, `libxss-dev`, `libxrandr-dev`. Chrome needs the runtime libraries (already listed above them), not the headers. `libpangocairo-1.0-0` is also listed twice (lines 27 and 40). Dropping the `-dev` set removes packages and their recommended toolchain pull-ins.

### 1.4 Build toolchains left in the runtime image

- `install_tippecanoe.sh` installs `build-essential` and `libsqlite3-dev`, compiles, but never removes them (its final chain only removes the source tree). `install_jekyll.sh` likewise installs `build-essential`/`zlib1g-dev` permanently.
- `env/gds_amd64.yml:214` ships the full **Rust toolchain** (`rust`) and `cython` inside the user environment. If they exist only to compile a pip package at build time, they don't belong in the shipped env (~500 MB+ for rust).
- Alternative for tippecanoe: build it in a multi-stage builder and `COPY` the two binaries, or take the package from a distro/conda-forge build.

### 1.5 Two Node.js installations across the family

- Base image: `install_jupyter_dev.sh:16` installs `nodejs>=22` into the base conda env.
- `frontend_agent/Dockerfile:33-35` adds Node 20 from NodeSource on top. Because `/opt/conda/bin` precedes `/usr/bin` on PATH in the jupyter stacks, the apt Node is largely shadowed — dead weight and a version contradiction (20 < 22). Reuse the conda Node for the npm-installed harnesses, or install one Node system-wide and drop the conda one.

### 1.6 Repeated installs of the same Python packages

`papermill` and `jupytext` are in the gds env (`env/gds_amd64.yml:48,35`); `jupytext` is pip-installed *again* into the base env (`install_jupyter_dev.sh:26`); and `frontend_agent/Dockerfile:52` pip-installs `papermill jupytext` into the gds env a third time (a guaranteed no-op or, worse, a version override of the conda install). At minimum drop the frontend_agent layer.

### 1.7 `frontend_code` image hygiene

`frontend_code/Dockerfile:8-9`: `apt-get install -y latexmk` without `--no-install-recommends` and without removing `/var/lib/apt/lists` — both contrary to the conventions used everywhere else in the repo. code-server is installed unpinned via `curl | sh` (see also 4.1).

### 1.8 Committed Jekyll build output

`docs/` (1.3 MB, 24 files) is the built copy of `website/` (380 KB source), committed on every site build by `.github/workflows/build_site.yml`. This is a deliberate GitHub-Pages-from-`docs/` setup, but the modern alternative (`actions/deploy-pages` from a workflow artifact) removes the built tree — and the recurring "Build website" commits — from history entirely.

### 1.9 Stale generated artifacts in-tree

`env/py/gds_py_explicit_*.txt` (4 files, ~535 lines each) were last written by the now-broken workflows in June 2024 (see 2.1) and no longer correspond to any produced environment. Either fix the workflows to regenerate them at the new paths or delete them.

---

## 2. Contradictions

### 2.1 CI references a directory that no longer exists

`test_python_environment_linux.yml`, `test_python_environment_macos.yml` and `test_windows_installer.yml` all operate on `gds_py/gds_py.yml`, `gds_py/check_py_stack.ipynb`, `gds_py/gds_py_win_installer.bat` — paths deleted in commit `a2c7e32` ("main big reorg into single Dockerfile under env", June 2024). They can only fail (they trigger on push to `master`). Meanwhile `docker/release_checklist.md` step "Confirm CI passes and explicit env files are written" assumes they work. Additional latent issues in the same files: `actions/checkout@v2` and `setup-miniconda@v2` (deprecated), `miniforge-variant: Mambaforge` (discontinued upstream in 2024), and `ad-m/github-push-action@master` with `force: true` (force-push to master from CI). Fix the paths and drop Windows-installer testing (the `.bat` installer no longer exists at all), or delete the workflows.

### 2.2 Version and image-name drift

| Location | Value | Note |
|---|---|---|
| `env/Dockerfile:6` | `11.0alpha` | default dev version |
| Root `Dockerfile:1` | `darribas/gds:11.0gc` | Binder image; `gc` tag exists but matches nothing documented |
| `frontend_code/compose.yml:3` | `gds_code:11.0alpha` | pre-release tag in the user-facing reference compose |
| `website/_config.yml` / `README.md` citation | `11.0` | release version |
| `.gitpod.yml` | `darribas/gds_dev:7.0` | **four majors old and a retired image name** |

The release checklist covers three of these; `.gitpod.yml` and `frontend_code/compose.yml` are not on it (the latter is mentioned but was left at `11.0alpha`). Either add them to `docker/release_checklist.md` or, better, reduce the number of places a version is written (see 3.9).

### 2.3 `ENV LANG` sets a single malformed variable

`env/Dockerfile:11`: `ENV LANG="C.UTF-8 LC_ALL=C.UTF-8"` assigns the literal string `C.UTF-8 LC_ALL=C.UTF-8` to `LANG` and never sets `LC_ALL`. Intended: `ENV LANG=C.UTF-8 LC_ALL=C.UTF-8`. Every published image currently has a broken `LANG`.

### 2.4 `install_r_extra.sh` is broken, disabled, and obsolete at once

- Line 2: `et -e` — typo for `set -e`, so the script would error on line 2 if ever run.
- `env/Dockerfile:29` has its invocation commented out.
- Its payload (install `tmap` from CRAN) exists because tmap v4 wasn't on conda — but `env/gds_amd64.yml:144` now has `r-tmap>=4` with the comment `# Off until v4 is on conda` still attached (the entry is *on*). Delete the script and fix the comment.

### 2.5 amd64 vs arm64 environment specs disagree beyond architecture

`diff env/gds_amd64.yml env/gds_arm64.yml` shows, besides the expected mass-commenting of R packages unavailable on arm64:

- `pysal` unpinned on amd64 vs `pysal==24.7` on arm64 — the two architectures can resolve different pysal releases.
- `myst_nb` present on amd64 (line 54) but absent from arm64's pip list.
- `polars-h3` and `simplification` commented out on arm64 with no explanatory note.
- `r-tmap>=4` on amd64 vs bare `r-tmap` on arm64.

Some of these may be deliberate platform constraints, but nothing distinguishes "unavailable on arm64" from "forgot to mirror the change" (see 3.1 for the structural fix).

### 2.6 `frontend_agent/SPEC.md` disagrees with the implementation

- SPEC line 21-22: "*We pin versions, we don't fork*" — the Dockerfile does the opposite by design: a `CACHEBUST` arg (`frontend_agent/Dockerfile:17-22`, `Makefile:90`) forces reinstalling **latest** harnesses on every build.
- SPEC lists baked models `qwen3.5:35b-a3b-coding-nvfp4` and `gemma4:26b-64k`; `opencode.json` actually ships `qwen3.6:*` and `gemma4:26b-a4b-it-qat*` with default `gemma4:26b-a4b-it-qat-64k`.
- SPEC's mounts table says `~/.config/gh` mounts for "`copilot` only"; `utils/gdsa` mounts it for `claude` (line 190) and `opencode` (line 263) too.
- SPEC says `gdsa update` pulls from "`main`"; the URL uses `master` (`utils/gdsa:21`) — `master` is correct, the SPEC is wrong.

If SPEC.md is meant to be a living document, reconcile it; if it was a one-off design doc, label it as historical.

### 2.7 Hard-coded LAN IP in the docker Jekyll config

`website/_config.docker.yml` contains `url: "http://192.168.1.93:4000"` — a machine-specific address committed to the repo, contradicting the `--host 0.0.0.0` intent of the `website_local` target it belongs to. Should be `http://localhost:4000` or documented as user-edited.

### 2.8 Makefile `website_local` has no-op / unreachable lines

`Makefile:63-71`: the trailing `export JEKYLL_ENV=development` runs in a *separate* shell (each recipe line is its own shell) and affects nothing; the `rm -rf _includes` chained after `jekyll serve` only runs when serve exits successfully (i.e. practically never, since serve is killed with Ctrl-C).

### 2.9 Jekyll toolchains conflict inside the image

`install_jekyll.sh:11` installs, in one gemset: `jekyll` (unpinned → 4.x), `github-pages` (which pins Jekyll **3.10**), `jekyll-scholar`, and `just-the-docs`. The `github-pages` meta-gem exists precisely to constrain Jekyll to GitHub's legacy version, so installing it alongside latest Jekyll guarantees a conflicting resolution (RubyGems will keep both and `bundle`-less invocations pick unpredictably). Meanwhile the site itself is built (in CI and via root `Gemfile`) with Jekyll `~> 4.3` and does *not* use `github-pages` (the Pages site is served from static `docs/` with `.nojekyll`). The `github-pages`, `jekyll-scholar` gems in the image look vestigial — pick the one toolchain the website actually uses.

### 2.10 Deprecated/undefined names in the Jupyter setup

- `install_conda_env.sh:29-30` writes `c.KernelSpecManager.whitelist` — deprecated since jupyter_client 7 (renamed `allowed_kernelspecs`); with the JupyterLab ≥ 4 stack shipped here it at best emits deprecation warnings and may be ignored entirely, which would defeat the intended kernel filtering. Verify against the running image and switch to `allowed_kernelspecs`.
- `env/Dockerfile:74`: `cd $NB_HOME` — `NB_HOME` is not defined anywhere (the jupyter stacks define `HOME`/`NB_USER`). It expands empty, and `cd` with no argument happens to go to `$HOME`, so it works by accident.
- `env/Dockerfile:15`: `ADD ./*/*.sh` is used where `COPY` is the documented best practice (ADD's extra semantics — URL fetch, tar auto-extract — are unwanted here).

### 2.11 Stale architecture descriptions in `env/*/README.md`

`env/py/README.md`, `env/r/README.md`, `env/dev/README.md` still describe the retired `gds_py` / `gds_dev` "flavour" architecture (`frontend_agent/SPEC.md:32` itself declares "Not the legacy `gds_py` — that's dead"). They should describe the current single-image layout, or be reduced to pointers at the check notebooks they accompany.

### 2.12 Docs links only valid after Jekyll assembly

`docker/install_guide.md` / `docker/build_guide.md` contain relative links (`../stacks/gds`, `../docker_install`) that resolve only once the files are copied into `website/_includes/` and rendered — read on GitHub in `docker/`, they 404. A one-line header comment in each file ("this file is included into the website; links are website-relative") would prevent confusion, or use absolute site URLs.

---

## 3. Duplication and streamlining

### 3.1 The two 214-line environment specs

`env/gds_amd64.yml` and `env/gds_arm64.yml` are the same document maintained twice, with arm64 divergence expressed as `#####`-commented lines. Every package change must be mirrored by hand, and 2.5 shows it already hasn't been. Options, in increasing order of rigour:

1. **Single spec + exclusion list:** one `gds.yml` plus a short `arm64_exclusions.txt`; a tiny script (run in `make build` or a pre-commit hook) generates the arch files. The diff *is* the exclusion list already.
2. **Two files, CI-checked:** keep both but add a check that the amd64/arm64 diff only contains lines from a declared allowlist.
3. Long term: track which R packages became available on `linux-aarch64` since the split — conda-forge arm64 coverage has improved substantially, and the `#####` blocks were probably written years ago.

### 3.2 Three near-identical CI workflows

`test_python_environment_linux.yml` and `test_python_environment_macos.yml` differ only in `runs-on` and the output filename; the Windows one differs only in the install step. When fixing them (2.1), collapse into one workflow with `strategy.matrix.os: [ubuntu-latest, macos-latest]` — with the Windows installer gone, its workflow should simply be deleted.

### 3.3 Makefile test/stack targets repeat one command four times

`Makefile:14-34`: the same `$(DOCKERRUN) $(image) start.sh …nbconvert --execute` line appears once per stack in `test` and again in each `test_py`/`test_r`/`test_dev`. A pattern rule removes the duplication and keeps `test` as an aggregate:

```make
test_%:
	$(DOCKERRUN) $(image) start.sh /opt/conda/envs/gds/bin/jupyter nbconvert \
	  --to html --execute /home/jovyan/test/env/$*/check_$*_stack.ipynb 2>&1 | tee env/test_$*.log
```

(Notebook names would need aligning: `check_py_stack` vs directory `py` already fits `check_$*_stack`.)

### 3.4 Installer scripts share boilerplate but not conventions

The 13 scripts in `env/installers/` each hand-roll `apt-get update … install … rm -rf /var/lib/apt/lists/*` and arch detection (`export ARCH=$(dpkg --print-architecture)` appears in four). More importantly, conventions differ where they should not:

- Only `install_decktape.sh` and `decktape_wrapper.sh` set `set -euo pipefail`. In the others, multi-statement scripts end with cleanup chains that succeed even when the payload failed, so the `RUN` reports success. Concretely: in `install_conda_env.sh` a failed `mamba env create` still lets the script fall through to `jupyter kernelspec remove -y python3` (which succeeds against the base env) — the build proceeds with **no gds environment**. Same masking pattern in `install_jupyter_dev.sh` (`npm cache clean` is the last command) and `install_jekyll.sh`/`install_latex_tools.sh`.
- A shared `set -euo pipefail` header (and optionally an `apt_install() { … }` helper sourced from one file) makes every script fail loudly and removes ~40 lines of repetition.

### 3.5 Dead legacy scripts still shipped into the image

`env/r/install_R.sh`, `install_R_gds.sh`, `install_R_stack.sh`, `setup_py-r.sh` are relics of the pre-2024 multi-image build; nothing references them. Because `env/Dockerfile:15` globs `ADD ./*/*.sh $HOME/scripts/`, they are copied into the build (and any edit to them invalidates the cache from that layer on). Delete them, and/or narrow the glob to `./installers/*.sh`.

### 3.6 Overlapping test notebooks

`env/py/` contains both `check_py_stack.ipynb` (34 cells, import-everything smoke test, used by `make test`) and `test_py_stack.ipynb` (4 cells running the *full upstream test suites* of geopandas/xarray/sklearn — hours of runtime, referenced by nothing in the repo). `env/r/test_courses.ipynb` (32 KB) is similarly unreferenced by Makefile or CI. If they are used manually, say so in the READMEs (2.11); otherwise remove them.

### 3.7 `frontend_agent/compose.yml` vs `gdsa`

Both encode the same run contract (mounts, env allowlist). This one is *documented* duplication (the compose header says exactly that), which is fine — but the two have already drifted in small ways (compose forwards `OPENAI_API_KEY`; `gdsa` doesn't, and SPEC's mount table matches neither exactly — see 2.6). Worth a comment discipline: when one changes, touch both.

### 3.8 DeckTape installer complexity

`install_decktape.sh` is 142 lines, over half of which is a three-stage fallback (find binary → unzip puppeteer's cached chrome zip → unzip headless-shell zip) needed because unpinned `npm install -g decktape` + `puppeteer/install.mjs`/`playwright@latest` behave differently across releases. Pinning the decktape and browser versions (e.g. `npx playwright@1.x install chromium`, or `@puppeteer/browsers install chrome@<build>`) would let the script shrink to ~30 deterministic lines *and* make builds reproducible. The runtime wrapper (`decktape_wrapper.sh`) is sound and can stay as is.

### 3.9 Version is written in too many places

`GDS_ENV_VERSION` (env/Dockerfile), root `Dockerfile`, `frontend_code/compose.yml`, `website/_config.yml`, `README.md` citation, `.gitpod.yml` — six hand-edited locations per release (the checklist tracks four). A single `VERSION` file read by the Makefile (`--build-arg GDS_ENV_VERSION=$(shell cat VERSION)`) plus templating for the website config would shrink the checklist and prevent the drift catalogued in 2.2.

---

## 4. Other improvements

### 4.1 Reproducibility / supply chain: pin what you run

Unpinned-at-build-time today: Quarto (`latest` from download JSON), Typst (`releases/latest`), tippecanoe (`git clone` HEAD), texcount (versioned URL — good), vim-plug (raw `master`), DeckTape + browser (`npm`/`npx @latest`), code-server (`curl | sh`), NodeSource setup script, `opencode` and `nb-cli` (`curl | bash` from HEAD), the notebook-cli skill (`git clone --depth 1` HEAD), and all npm harnesses (deliberately, via CACHEBUST). GPQ is the one exemplary pin (`v0.22.0`, `install_gpq.sh:8`). For a published teaching image, at minimum record resolved versions in the build log (partially done) and prefer pinned versions + checksums for the tools that define user-visible behaviour (Quarto, Typst, tippecanoe — e.g. clone a release tag). The agent image's "always latest" choice is defensible but should be stated in SPEC.md rather than contradicted by it (2.6).

### 4.2 No CI exercises the Dockerfiles

The only working workflow builds the website. The actual product — the image — is built and tested exclusively on a maintainer's machine (`docker/build_guide.md`). Even without pushing multi-GB images from CI, two cheap wins: (a) `hadolint` on all four Dockerfiles + `shellcheck` on `env/installers/*.sh` and `utils/gdsa` in a PR workflow (shellcheck would have caught `et -e` and the unquoted `${MOUNTS[@]}`-style pitfalls); (b) an on-demand (`workflow_dispatch`) build of `env/Dockerfile` to catch bit-rot between releases.

### 4.3 Makefile robustness

- `Makefile:3`: `DOCKERRUN = docker run -v \`pwd\`:…` — add `--rm` (each test/stack invocation currently leaves an exited container behind) and quote the volume: `-v "$(CURDIR)":/home/jovyan/test`.
- No `.PHONY` declarations at all — a file/directory named `test`, `build` or `docs` would silently disable the target (the repo *has* a `docs/` directory; it doesn't collide today only because no target is named `docs`).
- `ARCH := $(shell uname -m)` maps `x86_64→amd64` but not `aarch64→arm64` (`Makefile:11-13`); on a Linux arm64 host the image tag becomes `gds:<date>_aarch64` while the Dockerfile's `BUILDARCH` correctly says `arm64` — inconsistent tags for the same build.
- `make build` relies on BuildKit auto-populating `ARG BUILDARCH` (`env/Dockerfile:8`); with the legacy builder it is empty and the `ADD ./gds_.yml` fails cryptically. Passing `--build-arg BUILDARCH=$(ARCH)` from the Makefile costs one line and removes the assumption.

### 4.4 `gdsa` polish (small; the script is otherwise in good shape)

- `_cmd_update` (`utils/gdsa:328-339`) writes to `${BASH_SOURCE[0]}` — when installed as the documented symlink, `mv` replaces the *symlink itself* with a plain file, silently detaching the launcher from the repo checkout and breaking the `../frontend_agent/opencode.json` mounts that `SCRIPT_DIR` resolution otherwise provides. Resolve the symlink target before writing (the `_resolve_script_dir` helper already knows how).
- The `claude`/`copilot` subcommands run with `--dangerously-skip-permissions`/`--allow-all` while bind-mounting `~/.ssh` (ro) and `~/.config/gh` (rw) — i.e. the "container is the sandbox" posture still hands the agent push-capable credentials. That is a documented, deliberate trade-off (SPEC), but the SSH mount is not needed for the harness to *run*; consider making credential mounts opt-in (`--with-git-creds`) so `gdsa claude` on an untrusted repo defaults to no exfiltratable secrets.

### 4.5 Jupyter/base-vs-gds env layering deserves a written explanation

The runtime relies on a subtle arrangement: the Lab *server* and its extensions live in the base conda env (`install_jupyter_dev.sh` runs before the gds env exists), the gds env is a *kernel*, and `env/Dockerfile:26` prepends `/opt/conda/envs/gds/bin` to PATH so terminals resolve gds tools first. It works, but nothing in the repo says this is intentional, and several past bugs (kernel whitelist, default kernel name) live exactly at this seam. A short `env/README.md` section describing the two-env design would protect it from well-meaning "cleanup".

### 4.6 Root `Dockerfile` is unexplained in-tree

The two-line Binder shim (`FROM darribas/gds:11.0gc / RUN rm -rf ./work`) is only identifiable via `docker/release_checklist.md:26`. Add a comment header (`# Binder entrypoint — see release_checklist.md`) so it isn't mistaken for the main build.

### 4.7 Housekeeping

- `.gitignore` still carries `virtualbox/` rules for a directory that no longer exists.
- `frontend_code/compose.yml` ships `PASSWORD=<YOUR PASSWORD>` placeholder and maps port `4000` (Jekyll) without comment; a `#` note per line would make the reference compose self-explanatory.
- `frontend_agent/claude-settings.json` sets `"theme": "light"` while `tui.json` sets `"theme": "system"` — trivially inconsistent defaults.
- OCI labels: only `maintainer` is set (`env/Dockerfile:3`); adding `org.opencontainers.image.source/version/description` makes the Docker Hub images traceable back to the repo/commit.

---

## 5. Prioritised action plan

**Quick wins (small, safe, high value)**
1. Fix `ENV LANG` (2.3) and `cd $NB_HOME` (2.10) — two lines.
2. Add `--rm` to `DOCKERRUN`, `.PHONY`, `aarch64` mapping (4.3).
3. Delete dead code: `env/r/install_*.sh` + `setup_py-r.sh`, `install_r_extra.sh`, stale `gds_py_explicit_*.txt`, `.gitignore` relics (3.5, 2.4, 1.9).
4. Update `.gitpod.yml` or delete it; align `frontend_code/compose.yml` tag; reconcile SPEC.md (2.2, 2.6).

**Structural (medium effort, big payoff)**
5. Restructure `env/Dockerfile` cleanup into per-layer hygiene; move `fix-permissions` in-layer (1.1). Verify with `docker history` / dive before publishing.
6. `set -euo pipefail` across all installers; shared apt helper (3.4).
7. Fix or delete the three broken workflows; matrix-merge the survivors; add hadolint+shellcheck CI (2.1, 3.2, 4.2).
8. Single source of truth for the version (3.9) and for the env spec (3.1).

**Considered judgements (need a maintainer decision)**
9. One embedded browser instead of two (1.2); drop `rust`/`-dev` packages if nothing needs them at runtime (1.3, 1.4).
10. Pinning policy per image: strict pins for `gds`/`gds_code`, declared always-latest for `gds_agent` (4.1).
11. Migrate Pages deployment off the committed `docs/` tree (1.8).
