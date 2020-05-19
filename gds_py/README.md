# `gds_py`: a Python-only stack for Geographic Data Science

This folder contains the Python components of the `gds` Docker image. This can be accessed as part of the `gds` Docker image, or as a more lightweight image with Python-only libraries. For the latter, you can build it as:

```
docker build -t gds_py .
```

Or pull it directly from Docker Hub:

```
docker pull darribas/gds_py
```

## Native `conda` version

From `gds_py`, an [environment file](gds_py.yml) is automatically created for the stack built using `conda`. This is then tested on Windows/macOS/Linux:

| Platform  | Status |
| ------------- | ------------- |
| Linux/macOS  | [![Build Status](https://travis-ci.com/darribas/gds_env.svg?branch=master)](https://travis-ci.com/darribas/gds_env)  |
| Windows  | [![Build status](https://ci.appveyor.com/api/projects/status/pqgxg41qltt23o8o/branch/master?svg=true)](https://ci.appveyor.com/project/darribas/gds-env/branch/master)  |
