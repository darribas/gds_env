# The GDS stack

* [Dani Arribas-Bel](http://darribas.org)
  [[@darribas](http://twitter.com/darribas)]

This repository contains a `docker` container that includes:

* A full Python stack ready for geospatial analysis (see `gds_stack.yml` for a detailed list).
* A full R stack ready for geospatial analysis (see `install.R` for a detailed list).
* Both the [`IRkernel`](https://github.com/IRkernel/IRkernel) and [`rpy2`](https://bitbucket.org/rpy2/rpy2) channels to interact with R through Python.
* A full LaTeX distribution.
* Additional development utilities (e.g. `pandoc`, `git`, `decktape`, etc.).

It is rather heavy (around 10GB) but it is meant to provide a fully isolated environment that can be deployed in a wide array of contexts and encompass several situations.

## Requirements

You will need [Docker](https://www.docker.com) to be able to install the GDS environment.

## Installing

You can install this container by simply running:

> `docker pull darribas/gds`

[Note that you'll need [Docker](https://www.docker.com) installed on your machine]

## Building

If, instead, you want to build from source, the Docker image can be built by running:

> `docker build -t darribas/gds .`

You can check it has been built correctly by:

> `docker image ls`

And you should see one image with the name `gds`.

## Running

The container can be run as:

```
> docker run --rm -p 8787:8787 -v `pwd`:/home/gdser/host -it darribas/gds jupyter lab
```

<img src="JupyterLab.png" width="500">

A couple of notes on the command above:

* This opens the `8787` port of the container, so to access the Lab instance,
  you will have to point your browser to `localhost:8787` and insert the token
  printed on the terminal
* The command also mounts the current folder (`pwd`) to the container, but you can replace that with the path to any folder on your local machine (in fact, that will only work on host machines with the `pwd` command installed)

---

[<img src="gdsl.png" width="250">](https://www.liverpool.ac.uk/geographic-data-science/)

