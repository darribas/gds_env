---
layout: default
title: gds_py
parent: Stacks
nav_order: b
---

{% include gds_py_README.md %}

## Python Libraries

A full list of Python libraries installed in the `gds_py` environment is available below:

<details markdown="block">
  <summary type="button" name="button" class="btn">
    <code>`gds_py`</code> Python library list (click to expand)
  </summary>
    
    {% include stack_py.md %}

</details>

[Download table as `.txt`](https://github.com/darribas/gds_env/raw/master/gds_py/stack_py.txt){: .btn .btn }

## Install

The Docker image can be downloaded with the following command:

```
docker pull darribas/gds_py:{{ site.gds_env.version }}
```

## Native `conda` version

From `gds_py`, an environment file is automatically created for the stack built using `conda`. A list of libraries installed through `pip` are also available for download in a file. These are tested on Windows/macOS/Linux:

[![Test Python GDS Environment (Windows/macOS/Linux)](https://github.com/darribas/gds_env/actions/workflows/test_python_environment.yml/badge.svg)](https://github.com/darribas/gds_env/actions/workflows/test_python_environment.yml)

[Download `.yml` (including `pip` installs)](https://github.com/darribas/gds_env/raw/master/gds_py/gds_py.yml){: .btn .btn }

