# Python: `gds_py`

The core of the `gds_env` is `gds_py`: a container providing a fully working Jupyter Lab installation, additionally loaded with a comprehensive list of geospatial python packages.

To build `gds_py`, we start with the [`minimal-notebook`](https://github.com/jupyter/docker-stacks/tree/master/minimal-notebook) image of the Jupyter official Docker images. This means `gds_py` comes with the following preinstalled and available to the user:

- Jupyter (Lab/Notebook/Hub)
- LaTeX distribution (allowing to export notebooks into pdf, for example)
- `pandoc` for document conversion

For more information on the components of `minimal-notebook`, please check the [Jupyter Docker Stacks](https://jupyter-docker-stacks.readthedocs.io/) documentation.

On top of `minima-notebook`, we add a comprehensive list of geospatial pacakges in Python. For a full list, see the table below.

## Native `conda` version

From `gds_py`, an [environment file](https://github.com/darribas/gds_env/raw/master/gds_py/gds_py.yml) is automatically created for the stack built using `conda`. This is then tested on Windows/macOS/Linux:

| Platform  | Status |
| ------------- | ------------- |
| Linux/macOS  | [![Build Status](https://travis-ci.com/darribas/gds_env.svg?branch=master)](https://travis-ci.com/darribas/gds_env)  |
| Windows  | [![Build status](https://ci.appveyor.com/api/projects/status/pqgxg41qltt23o8o/branch/master?svg=true)](https://ci.appveyor.com/project/darribas/gds-env/branch/master)  |
