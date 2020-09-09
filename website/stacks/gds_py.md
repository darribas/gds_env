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

| Platform  | Status |
| ------------- | ------------- |
| Linux/macOS  | [![Build Status](https://travis-ci.com/darribas/gds_env.svg?branch=master)](https://travis-ci.com/darribas/gds_env)  |
| Windows  | [![Build status](https://ci.appveyor.com/api/projects/status/pqgxg41qltt23o8o/branch/master?svg=true)](https://ci.appveyor.com/project/darribas/gds-env/branch/master)  |

[Download `.yml`](https://github.com/darribas/gds_env/raw/master/gds_py/gds_py.yml){: .btn .btn }
[Download pip `.txt`](https://github.com/darribas/gds_env/raw/master/gds_py/gds_py_pip.txt){: .btn .btn }

