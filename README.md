# The GDS stack

* [Dani Arribas-Bel](http://darribas.org)
  [[@darribas](http://twitter.com/darribas)]

This repository contains a `conda` environment with Jupyter Lab and a
comprehensive and opinionated list of Python and R packages for Geographic 
Data Science. 

The environment can be installed natively on a machine:

> `conda-env create -f install_gds_stack.yml`

Or built as a Docker container (for which you will need [Docker](https://www.docker.com)):

> `docker build -t gds .

The container can be run as:

> `docker run --rm -p 8888:8888 -v /Users/dani/:/gds -i -t gds start.sh`

| OS      | Status |
| ------- | -----------------|
| Linux & macOS   | [![Build Status](https://travis-ci.org/darribas/gds_env.svg?branch=master)](https://travis-ci.org/darribas/gds_env) |
| Windows | [![Build status](https://ci.appveyor.com/api/projects/status/9l1j8ku9pdq7j91f?svg=true)](https://ci.appveyor.com/project/darribas/gds-env) |

---

[<img src="gdsl.png" width="250">](https://www.liverpool.ac.uk/geographic-data-science/)

---

ToDo:

- R packages to install:
    - `tufte`
    - `tmap`
    - `GISTools`
- Update python check notebook
- Create R check notebook

