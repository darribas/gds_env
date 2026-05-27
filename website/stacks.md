---
layout: default
title: Stacks
nav_order: b 
has_children: true
has_toc: false
---

# Stacks

The `gds_env` provides a Jupyter-based platform to run Python and R geospatial packages in a way that can be deployed in a variety of contexts.

Two variants are available:

- [`gds`](gds): the core image — Jupyter + Python geospatial libraries + R geospatial libraries + development tools
- [`gds_code`](gds_code): `gds` with [code-server](https://github.com/coder/code-server) added, providing a VS Code interface in the browser

For most users, `gds` is the right starting point. `gds_code` is for users who prefer a VS Code environment over JupyterLab.
