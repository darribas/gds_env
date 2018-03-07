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
- Launch RStudio
- Update python check notebook
- Create R check notebook

```
> warnings()
Warning messages:
1: In install.packages("tmap", dep = T, , repos = "http://cran.rstudio.com/") :
  installation of package ‘udunits2’ had non-zero exit status
2: In install.packages("tmap", dep = T, , repos = "http://cran.rstudio.com/") :
  installation of package ‘XML’ had non-zero exit status
3: In install.packages("tmap", dep = T, , repos = "http://cran.rstudio.com/") :
  installation of package ‘protolite’ had non-zero exit status
4: In install.packages("tmap", dep = T, , repos = "http://cran.rstudio.com/") :
  installation of package ‘jqr’ had non-zero exit status
5: In install.packages("tmap", dep = T, , repos = "http://cran.rstudio.com/") :
  installation of package ‘V8’ had non-zero exit status
6: In install.packages("tmap", dep = T, , repos = "http://cran.rstudio.com/") :
  installation of package ‘units’ had non-zero exit status
7: In install.packages("tmap", dep = T, , repos = "http://cran.rstudio.com/") :
  installation of package ‘gdtools’ had non-zero exit status
8: In install.packages("tmap", dep = T, , repos = "http://cran.rstudio.com/") :
  installation of package ‘geojson’ had non-zero exit status
9: In install.packages("tmap", dep = T, , repos = "http://cran.rstudio.com/") :
  installation of package ‘jsonvalidate’ had non-zero exit status
10: In install.packages("tmap", dep = T, , repos = "http://cran.rstudio.com/") :
  installation of package ‘svglite’ had non-zero exit status
11: In install.packages("tmap", dep = T, , repos = "http://cran.rstudio.com/") :
  installation of package ‘rgdal’ had non-zero exit status
12: In install.packages("tmap", dep = T, , repos = "http://cran.rstudio.com/") :
  installation of package ‘rgeos’ had non-zero exit status
13: In install.packages("tmap", dep = T, , repos = "http://cran.rstudio.com/") :
  installation of package ‘geojsonlint’ had non-zero exit status
14: In install.packages("tmap", dep = T, , repos = "http://cran.rstudio.com/") :
  installation of package ‘osmar’ had non-zero exit status
15: In install.packages("tmap", dep = T, , repos = "http://cran.rstudio.com/") :
  installation of package ‘gdalUtils’ had non-zero exit status
16: In install.packages("tmap", dep = T, , repos = "http://cran.rstudio.com/") :
  installation of package ‘cartogram’ had non-zero exit status
17: In install.packages("tmap", dep = T, , repos = "http://cran.rstudio.com/") :
  installation of package ‘sf’ had non-zero exit status
18: In install.packages("tmap", dep = T, , repos = "http://cran.rstudio.com/") :
  installation of package ‘geojsonio’ had non-zero exit status
19: In install.packages("tmap", dep = T, , repos = "http://cran.rstudio.com/") :
  installation of package ‘rmapshaper’ had non-zero exit status
20: In install.packages("tmap", dep = T, , repos = "http://cran.rstudio.com/") :
  installation of package ‘tmaptools’ had non-zero exit status
21: In install.packages("tmap", dep = T, , repos = "http://cran.rstudio.com/") :
  installation of package ‘mapview’ had non-zero exit status
22: In install.packages("tmap", dep = T, , repos = "http://cran.rstudio.com/") :
  installation of package ‘tmap’ had non-zero exit status
>
```
