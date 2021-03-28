#!/bin/bash

set -e

# always set this for scripts but don't declare as ENV..
export DEBIAN_FRONTEND=noninteractive

#--- Utilities ---#

apt-get update -qq \
  && apt-get install -y --no-install-recommends software-properties-common \
  && add-apt-repository -y ppa:ubuntugis/ubuntugis-unstable \
  && apt-get update -qq \
  && apt-get install -y --no-install-recommends \
    gpg-agent \
    jq \
    libatk1.0-0 \
    libv8-dev \
    libx11-6 \
    libxtst6 \
 && apt-get autoclean \
 && apt-get autoremove \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

#--- R ---#
# https://github.com/rocker-org/rocker-versioned/blob/master/r-ver/Dockerfile
# Look at: http://sites.psu.edu/theubunturblog/installing-r-in-ubuntu/

echo "deb https://cloud.r-project.org/bin/linux/ubuntu focal-cran40/" >> /etc/apt/sources.list \
 && sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E298A3A825C0D65DFD57CBB651716619E084DAB9 \
 && apt-get update \
 && apt-get install -y \
    r-base \
    r-base-dev \
 && apt-get autoclean \
 && apt-get autoremove \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

#--- R libs ---#
# SAN requirements (on top of Rocker Geospatial)
# https://github.com/GDSL-UL/san/blob/master/01-overview.Rmd
R -e "install.packages(c( \
            'arm', \
            'car', \
            'corrplot', \
            'FRK', \
            'gghighlight', \
            'ggmap', \
            'GISTools', \
            'jtools', \
            'kableExtra', \
            'knitr', \
            'lme4', \
            'lmtest', \
            'lubridate', \
            'MASS', \
            'merTools', \
            'sjPlot', \
            'spgwr', \
            'stargazer', \
            'viridis' \
            ), repos='https://cran.rstudio.com');"
# ------------------
# Other
R -e "install.packages(c( \
            'areal', \
            'deldir', \
            'feather', \
            'geojsonio', \
            'hexbin', \
            'igraph', \
            'nlme', \
            'patchwork', \
            'randomForest', \
            'RCurl', \
            'rpostgis', \
            'shiny', \
            'splancs', \
            'TraMineR', \
            'tufte' \
            ), repos='https://cran.rstudio.com');"

## Geocomputation in R meta-package
R -e "library(devtools); \
      devtools::install_github('geocompr/geocompkg');"

