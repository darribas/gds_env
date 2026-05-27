---
layout: default
title: gds_code
parent: Stacks
nav_order: b
---

# `gds_code`

`gds_code` is a variant of [`gds`](gds) that replaces the JupyterLab interface with [code-server](https://github.com/coder/code-server) — a browser-based VS Code environment. It includes the full `gds` software stack (Python, R, and all development tools) with VS Code as the front end.

## Additional contents

On top of everything in [`gds`](gds), `gds_code` adds:

- [code-server](https://github.com/coder/code-server) — VS Code in the browser
- Pre-installed VS Code extensions:
  - [Quarto](https://marketplace.visualstudio.com/items?itemName=quarto.quarto)
  - [Jupyter](https://marketplace.visualstudio.com/items?itemName=ms-toolsai.jupyter)
  - [Python](https://marketplace.visualstudio.com/items?itemName=ms-python.python)
  - [LaTeX Workshop](https://marketplace.visualstudio.com/items?itemName=james-yu.latex-workshop)
  - [Vim](https://marketplace.visualstudio.com/items?itemName=vscodevim.vim)
  - [Catppuccin theme](https://marketplace.visualstudio.com/items?itemName=Catppuccin.catppuccin-vsc)

## Build

`gds_code` is built on top of an existing `gds` image. From the repo root:

```shell
make build_code image=darribas/gds:{{ site.gds_env.version }}
```

## Run

```shell
docker run --rm -p 8443:8080 -e PASSWORD=<your-password> \
  -v ${PWD}:/home/jovyan/work \
  gds_code:{{ site.gds_env.version }}
```

Then point your browser to `localhost:8443`. Or use the provided `compose.yml` in `frontend_code/` for a persistent setup.
