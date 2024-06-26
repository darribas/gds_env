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
    libmagick++-dev \
    libv8-dev \
    libx11-6 \
    libxtst6 \
    lmodern \
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
            'caret', \
            'deldir', \
            'factoextra', \
            'feather', \
            'geojsonio', \
            'ggimage', \
            'ggcorrplot', \
            'ggformula', \
            'ggpmisc', \
            'ggthemes', \
            'glmmTMB', \
            'hexbin', \
            'igraph', \
            'mapboxapi', \
            'mapdeck', \
            'Metrics', \
            'modelsummary', \
            'nlme', \
            'osrmj', \
            'patchwork', \
            'plotly', \
            'plotrix', \
            'randomForest', \
            'ranger', \
            'RCurl', \
            'RedditExtractoR', \
            'rpart.plot', \
            'rpostgis', \
            'rtweet', \
            'shiny', \
            'showtext', \
            'SnowballC', \
            'splancs', \
            'stm', \
            'stplanr', \
            'textdata', \
            'tidycensus', \
            'tidygeocoder', \
            'tidytext', \
            'tm', \
            'topicmodels', \
            'TraMineR', \
            'tufte', \
            'vader', \
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

