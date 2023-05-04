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
    cmake \
    gpg-agent \
    jq \
    libatk1.0-0 \
    libv8-dev \
    libx11-6 \
    libxtst6 \
    lmodern \
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
            'bookdown', \
            'brms', \
            'deldir', \
            'factoextra', \
            'feather', \
            'geojsonio', \
            'ggcorrplot', \
            'ggthemes', \
            'glmmTMB', \
            'hexbin', \
            'igraph', \
            'mapboxapi', \
            'nlme', \
            'osrmj', \
            'patchwork', \
            'plotrix', \
            'randomForest', \
            'RCurl', \
            'RedditExtractoR', \
            'rpostgis', \
            'rtweet', \
            'shiny', \
            'SnowballC', \
            'splancs', \
            'stm', \
            'tidycensus' \
            'tidytext', \
            'tm', \
            'topicmodels', \
            'TraMineR', \
            'tufte' \
            'vader' \
            'wellknown' \
            ), repos='https://cran.rstudio.com');"

# Arrow libs and other GH installs
R -e "install.packages(c( \
            'remotes' \
            ), repos='https://cran.rstudio.com'); \
      library(remotes); \
      remotes::install_github('wpgp/wpgpDownloadR'); \
      remotes::install_github('maraab23/ggseqplot'); \
      remotes::install_github('paleolimbot/geoarrow');"
# sfarrow
# Following https://github.com/wcjochem/sfarrow/issues/10#issuecomment-867639952
R -e "Sys.setenv(ARROW_S3='ON'); \
      Sys.setenv(NOT_CRAN='true'); \
      install.packages( \
        'arrow', repos = 'https://arrow-r-nightly.s3.amazonaws.com' \
        );\
      install.packages('sfarrow', repos='https://cran.rstudio.com');"
# geoarrow: https://paleolimbot.github.io/geoarrow/
R -e "library(remotes); \
      remotes::install_github('paleolimbot/geoarrow');"

## Geocomputation in R meta-package
R -e "library(remotes); \
      remotes::install_github('geocompr/geocompkg');"

