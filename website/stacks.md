---
layout: default
title: Stacks
nav_order: b 
has_children: true
has_toc: false
---

# Stacks

The `gds_env` provides a Jupyter-based platform to run Python and R geospatial packages in a way that can be installed in a variety of contexts. To provide more flexibility and better cater to the needs of different users, this overall functionality is stratified in three different flavours, or stacks: [`gds_py`](gds_py), [`gds`](gds) and [`gds_dev`](gds_dev).

![Stacks](diagram.png)

All of the stacks are based on Jupyter [Lab](https://jupyterlab.readthedocs.io/en/stable/)/[Notebook](https://jupyter-notebook.readthedocs.io/en/latest/)/[Hub](https://jupyter.org/hub) and on [Docker](https://www.docker.com/). The main difference is the overall functionality they provide (and the subsequent size of each image).

The three stacks are layered on top of each other:

- [`gds_py`](gds_py): Jupyter official [`minimal-notebook`](https://jupyter-docker-stacks.readthedocs.io/en/latest/using/selecting.html#jupyter-minimal-notebook) (Jupyter Lab/Notebook/Hub + LaTeX) + Python geospatial libraries (see [full list](gds_py#python-libraries))
- [`gds`](gds): [`gds_py`](gds_py) + R geospatial libraries (see [full list](gds#r-libraries)) + [`IRkernel`](https://github.com/IRkernel/IRkernel) + [`rpy2`](https://bitbucket.org/rpy2/rpy2)
- [`gds_dev`](gds_dev): [`gds`](gds) + development tools ([`decktape`](https://github.com/astefanutti/decktape), [`jekyll`](https://jekyllrb.com/), [`tippecanoe`](https://github.com/mapbox/tippecanoe))

For further details, be sure to check the page of each stack.
