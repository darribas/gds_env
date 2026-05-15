---
layout: default
title: gds
parent: Stacks
nav_order: a
---

# `gds`

The `gds` image is the core of the `gds_env`. It extends the official Jupyter [`minimal-notebook`](https://jupyter-docker-stacks.readthedocs.io/en/latest/using/selecting.html#jupyter-minimal-notebook) with a comprehensive geospatial stack for both Python and R, plus a set of development tools.

## Contents

**Base**
- [JupyterLab](https://jupyterlab.readthedocs.io/en/stable/), Notebook, and Hub
- LaTeX distribution and `pandoc` (for PDF/document export)

**Python geospatial libraries** — including `geopandas`, `pysal`, `rasterio`, `xarray`, `osmnx`, `dask-geopandas`, `contextily`, `movingpandas`, `momepy`, and many more. Full list below.

**R geospatial libraries** — including `sf`, `terra`, `spdep`, `tmap`, `tidyverse`, `ggplot2`, and many more, with an R kernel for Jupyter via [`IRkernel`](https://github.com/IRkernel/IRkernel) and Python↔R interop via [`rpy2`](https://rpy2.github.io/). Full list below.

**Development tools**
- [Quarto](https://quarto.org/) — scientific publishing system
- [Jekyll](https://jekyllrb.com/) — static site generator
- [tippecanoe](https://github.com/mapbox/tippecanoe) — vector tileset builder
- [decktape](https://github.com/astefanutti/decktape) — HTML slides → PDF
- [gpq](https://github.com/planetlabs/gpq) — GeoParquet validator
- [Vim](https://www.vim.org/) — terminal editor

## Package lists

Full lists of installed packages are available for each release on the repository:

- [Python stack (amd64)](https://github.com/darribas/gds_env/blob/master/env/py/stack_py_amd64.md)
- [Python stack (arm64)](https://github.com/darribas/gds_env/blob/master/env/py/stack_py_arm64.md)
- [R stack (amd64)](https://github.com/darribas/gds_env/blob/master/env/r/stack_r_amd64.md)
- [R stack (arm64)](https://github.com/darribas/gds_env/blob/master/env/r/stack_r_arm64.md)

## Install

Pull the image from Docker Hub:

```shell
docker pull darribas/gds:{{ site.gds_env.version }}
```

For instructions on running the image, see the [Docker install guide](../guides/docker_install).
