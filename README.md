# The GDS stack

* [Dani Arribas-Bel](http://darribas.org)
  [[@darribas](http://twitter.com/darribas)]

This repository contains a `docker` container that includes:

* A full Python stack ready for geospatial analysis (see `gds_stack.yml` for a detailed list).
* A full R stack ready for geospatial analysis (see `install.R` for a detailed list).
* Both the [`IRkernel`](https://github.com/IRkernel/IRkernel) and [`rpy2`](https://bitbucket.org/rpy2/rpy2) channels to interact with R through Python.
* A full LaTeX distribution.
* Additional development utilities (e.g. `pandoc`, `git`, etc.).

It is rather heavy (around 10GB) but it is meant to provide a fully isolated environment that can be deployed in a wide array of contexts and encompass several situations.

## Requirements

You will need [Docker](https://www.docker.com) to be able to install the GDS environment.

## Building

The Docker image can be built by running:

> `docker build -t gds .`

You can check it has been built correctly by:

> `docker image ls`

And you should see one image with the name `gds`.

## Running

The container can be run as:

> `docker run --rm -p 8787:8787 -v `pwd`:/gds -it gds`

Note that this opens the `8787` port of the container, so if you want to access server-based applications from the container (ie. Jupyter Lab or RStudio), you will need to point your browser to `localhost:8787`. The command also mounts the current folder (`pwd`) to the container, but you can replace that with any path.

### Jupyter Lab

<img src="JupyterLab.png" width="500">

Once in the container, you can launch Jupyter Lab by runing:

> `start_jupyterlab`

Which is a short for:

> `jupyter lab --port=8787 --no-browser --ip='*' --allow-root`

### RStudio

<img src="rstudio.png" width="500">

The container includes also a full install of RStudio server. To access it, you need to run a slightly different start command:

> `docker run --rm -p 8787:8787 -v `pwd`:/home/rstudio -it gds`

Once inside the container, you can start RStudio by running:

> `start_rstudio`

Which is also a short for:

> `/init`

---

## Known issues

Currently, both R and Python work as expected. However, the following issues are known:

- `JuniperKernel` does not display graphics ([#3](https://github.com/darribas/gds_env/issues/1)). This issue has been worked around by using `IRkernel`

---


| OS      | Status |
| ------- | -----------------|
| Linux & macOS   | [![Build Status](https://travis-ci.org/darribas/gds_env.svg?branch=master)](https://travis-ci.org/darribas/gds_env) |
| Windows | [![Build status](https://ci.appveyor.com/api/projects/status/9l1j8ku9pdq7j91f?svg=true)](https://ci.appveyor.com/project/darribas/gds-env) |

---

[<img src="gdsl.png" width="250">](https://www.liverpool.ac.uk/geographic-data-science/)

