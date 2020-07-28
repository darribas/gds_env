---
layout: default
title: gds
parent: Stacks
nav_order: c 
---

{% include gds_README.md %}

## R Libraries

A full list of Python libraries installed in the `gds_py` environment is available below:

<details markdown="block">
  <summary>
    <code>`gds`</code> R library list
  </summary>
    
    {% include stack_r.txt %}

</details>

## Install

The Docker image can be downloaded with the following command:

```
docker pull darribas/gds:{{ site.gds_env.version }}
```
