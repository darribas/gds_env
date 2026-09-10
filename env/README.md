# `env/` — the two-environment design

The `gds` image runs **two conda environments on purpose**. Which one you get
depends on *how* you arrive, and the two answers are different. Several past
bugs live exactly here, so this file records the arrangement and how to
re-verify it.

Read this before "simplifying" one environment into the other (audit 4.5).

| | **base** (`/opt/conda`) | **gds** (`/opt/conda/envs/gds`) |
|---|---|---|
| Python | 3.13 | 3.12 |
| Role | **Serves JupyterLab** + its extensions | **Kernel** + the user-facing toolchain |
| Built by | `installers/install_jupyter_dev.sh` | `installers/install_conda_env.sh` from `env/gds.yml` |
| Holds | Lab, labextensions, `bash_kernel` | the whole geospatial stack, R, Quarto-adjacent tooling |
| You meet it as | the Lab UI in your browser | the `GDS` / `gdsR` kernels, and anything you type in a terminal |

## Why two

`install_jupyter_dev.sh` runs at `Dockerfile:28`; the gds env is not created
until `Dockerfile:34`. The Lab server therefore *cannot* live in gds — it is
installed before gds exists. That ordering is the origin of the split, and it
turns out to be a good arrangement anyway: the server keeps its own dependency
set, so a solve conflict in the user stack cannot take the UI down with it.

## The crux: two different PATH resolutions

`env/Dockerfile:33` sets an image-wide

```dockerfile
ENV PATH="/opt/conda/envs/gds/bin/:${PATH}"
```

so at image level **gds comes first**. But that is not the whole story, and
believing it is will lead you to the wrong conclusion.

### The server resolves to **base**

`start.sh` sources `/usr/local/bin/before-notebook.d/10activate-conda-env.sh`
*before* launching anything. That hook is one line:

```bash
eval "$(conda shell.bash hook)"
```

which **activates `base`** — its own comment says so — prepending
`/opt/conda/bin` ahead of the gds entry. Then `start-notebook.py` ends with

```python
os.execvp("jupyter", command)     # a bare name: PATH lookup
```

so the server that starts is `/opt/conda/bin/jupyter`. **base serves Lab.**

```console
$ command -v jupyter                     # image PATH, no hook yet
/opt/conda/envs/gds/bin/jupyter
$ eval "$(conda shell.bash hook)"        # what the hook does
$ command -v jupyter
/opt/conda/bin/jupyter                   # <- this is what serves
```

### Terminals resolve to **gds**

`install_conda_env.sh` appends `conda activate gds` to `~/.bashrc`, so an
interactive shell activates gds and gets the geospatial stack, R, and the
user-facing tools. That is the intent of the `ENV PATH` line too.

### So

**Same image, two resolution orders, decided by which process you are.** A
non-interactive `docker exec … jupyter` is a *third* case: it gets neither the
hook nor `.bashrc`, so it hits the raw `ENV PATH` and resolves to gds. If you
are checking which Lab serves, do it the way the server does, or you will
measure the wrong one.

## Kernels

```
gds      -> /opt/conda/envs/gds/bin/python     (Python 3.12, the geospatial stack)
ir       -> /opt/conda/envs/gds/lib/R/bin/R    (R, installed by IRkernel)
bash     -> /opt/conda/bin/python              (bash_kernel, lives in base)
python3  -> /opt/conda/bin/python              (base's own; hidden, see below)
```

`gds` and `ir` are the ones users want. `bash` comes from base because
`bash_kernel` is installed there. Kernelspecs record **absolute** interpreter
paths, which is why a base-env server can happily launch a gds-env kernel —
that is the whole seam in one sentence.

## The config knobs at the seam

`install_conda_env.sh` writes three lines into
`~/.jupyter/jupyter_lab_config.py`:

```python
c.MultiKernelManager.default_kernel_name = 'gds'          # open notebooks on gds, not base
c.KernelSpecManager.ensure_native_kernel = False          # don't synthesise one for the server's own env
c.KernelSpecManager.allowed_kernelspecs = {'gds','ir','bash'}   # show only these
```

All three exist to stop the *server's own* environment leaking into the kernel
picker. Remove any of them and users get a `python3` kernel that runs base —
Python 3.13 with none of the geospatial stack — which looks like a broken
image rather than a wrong choice.

`allowed_kernelspecs` was called `whitelist` until audit 2.10. Contrary to
what that finding assumed, the old name was **never silently ignored** — on
jupyter_client 8.9.1 it still filters correctly and merely warns
`KernelSpecManager.whitelist is deprecated in jupyter_client 7.0`. Verified by
passing each name explicitly; both drop `python3` from the list. The rename
was still right, since deprecated traits do eventually go, but it fixed a
warning rather than a live bug.

Note `jupyter kernelspec list` will **not** show you this filtering. That CLI
reads `jupyter_config.py`, not `jupyter_lab_config.py`, so it lists what is on
disk — including `python3`. To see what the Lab picker offers, ask the running
server: `curl -s localhost:8888/api/kernelspecs`.

## Deliberate duplication

Three things exist in both environments. None is an accident:

- **`jupytext`** — base's copy backs the `jupyterlab-jupytext` *extension* in
  the serving Lab; gds's copy is for notebook code and the CLI. Removing the
  base one breaks the Lab integration (audit 1.6).
- **`nodejs`** — base gets it from `install_jupyter_dev.sh`; gds gets it as a
  dependency. `gds_agent`'s npm-installed harnesses use whichever PATH gives
  them, which is gds's (audit 1.5).
- **Compilers** — the gds env has a conda GCC because **`r-base` depends on
  it**, and R's `Makeconf` points at it, so `install.packages()` compiles with
  the conda toolchain. Python is the opposite: `sysconfig` reports a bare
  `CC = gcc`, so `pip install` of an sdist falls through to `/usr/bin/gcc`
  from apt's `build-essential`. **Both toolchains are load-bearing, for
  different languages** (audit 1.4).

## Things that look like bugs and are not (or are)

- **`jupyter kernelspec remove` targets the active env.**
  `install_conda_env.sh` runs it with gds activated, so the build log reads
  `Removed /opt/conda/envs/gds/share/jupyter/kernels/python3` — the *gds*
  one. Base's `python3` kernelspec survives at
  `/opt/conda/share/jupyter/kernels/python3` and is masked by
  `allowed_kernelspecs`, not deleted. That is fragile: the mask is doing the
  work the removal was meant to do.
- **Two JupyterLabs.** base has 4.6.2 and serves; gds has 4.6.3 and does not.
  Nothing in the gds env depends on `jupyterlab` — it is there because
  `env/gds.yml` lists it explicitly. It is also the reason a bare
  `command -v jupyter` finds the *non-serving* Lab. Whether the gds entry
  still earns its place is an open question; see below.

## Open questions

- Does the gds env need `jupyterlab` at all? Nothing depends on it, and it is
  not what serves. Removing it would want a check that nothing in a terminal
  workflow (`jupyter nbconvert`, `jupyter-book`) relies on it, and a rebuild.
- `jupyterlab-myst` is installed into base but incompatible with the bundled
  Lab, so it never loads — see issue #132.

## How to re-verify all of this

From inside a running container:

```bash
eval "$(conda shell.bash hook)"      # reproduce the server's PATH
command -v jupyter                   # -> /opt/conda/bin/jupyter
jupyter labextension list            # what the serving Lab actually loads
jupyter kernelspec list              # and where each kernel points
```

Check the *server's* view, not a bare shell's. Getting this backwards is easy;
it happened while writing this file.
