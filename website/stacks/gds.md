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
  <summary type="button" name="button" class="btn">
        <code>`gds`</code> R library list (click to expand)
  </summary>
    
    {% include stack_r.txt %}

</details>

## Install

The Docker image can be downloaded with the following command:

```
docker pull darribas/gds:{{ site.gds_env.version }}
```
