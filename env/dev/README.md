# `env/dev` — developer tooling checks

This directory holds the verification for the CLI tooling layered on top of the
conda env, plus the assets those installers need:

- `check_dev_stack.ipynb` — the check notebook. Exercises the command-line tools
  end to end (not just "is it on PATH"), including the DeckTape and
  `jupyter-book` PDF/Typst export paths that have regressed before.
- `texBuild.py`, `install_texbuild.py`, `vimrc` — files copied into the image by
  `env/Dockerfile`.

The notebook exercises [`decktape`](https://github.com/astefanutti/decktape)
(HTML slides → PDF), [`quarto`](https://quarto.org/),
[`typst`](https://typst.app/), [`tippecanoe`](https://github.com/mapbox/tippecanoe)
(vector tilesets) and the TinyTeX-based LaTeX toolchain end to end;
[`jekyll`](https://jekyllrb.com/) and `gpq` are covered by a version check only.
Vim is installed by `env/installers/install_vim.sh` but is not checked here.

## How it is used

```bash
make test_dev image=gds:<tag>   # runs check_dev_stack.ipynb inside the image
```

`make test` runs this alongside the Python and R checks. Output lands in
`env/test_dev.log`.

## Where these tools are installed

Not here. Each is installed by its own script in `env/installers/`, invoked in
order from `env/Dockerfile`. Add a tool there, then add a check for it to
`check_dev_stack.ipynb`.
