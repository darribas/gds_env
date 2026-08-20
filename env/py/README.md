# `env/py` — Python stack checks

This directory holds the Python-side verification for the `gds` image:

- `check_py_stack.ipynb` — the check notebook. Imports every Python package the
  image is expected to provide and exercises a few of them.
- `test_py_stack.ipynb` — a longer, exploratory notebook kept for manual runs.
- `stack_py_<arch>.txt` / `stack_py_<arch>.md` — generated listings of what
  `conda list -n gds` actually resolved to, one pair per architecture.

## How it is used

```bash
make test_py image=gds:<tag>    # runs check_py_stack.ipynb inside the image
make write_py_stack image=gds:<tag>  # regenerates the stack_py_* listings
```

`make test` runs this alongside the R and dev checks. Output lands in
`env/test_py.log`.

## Where the package list lives

Not here. Packages are declared in `env/gds_amd64.yml` / `env/gds_arm64.yml`
(one conda env, `gds`, carrying both Python and R). The `stack_py_*` files are
**generated** — record what a build produced, never edit them by hand.
