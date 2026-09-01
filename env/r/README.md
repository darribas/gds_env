# `env/r` — R stack checks

This directory holds the R-side verification for the `gds` image:

- `check_r_stack.ipynb` — the check notebook. Loads every R library the image is
  expected to provide, via the [`IRkernel`](https://github.com/IRkernel/IRkernel)
  kernel.
- `test_courses.ipynb` — a longer, exploratory notebook kept for manual runs.
- `stack_r_<arch>.txt` / `stack_r_<arch>.md` — generated listings of the
  installed R packages, one pair per architecture.

## How it is used

```bash
make test_r image=gds:<tag>          # runs check_r_stack.ipynb inside the image
make write_r_stack image=gds:<tag>   # regenerates the stack_r_* listings
```

`make test` runs this alongside the Python and dev checks. Output lands in
`env/test_r.log`.

## Where the package list lives

Not here. R packages are declared as `r-*` entries in `env/gds.yml` — the same
conda env that carries the Python stack, and the source of truth for every
architecture. Packages conda-forge does not build for `linux-aarch64` carry a
`# !arm64:` flag naming the reason and the date checked; the generator drops
them from the arm64 spec, so the two architectures do not ship an identical R
stack. Thirteen entries are flagged today. The `stack_r_*` files are
**generated** — never edit them by hand.
