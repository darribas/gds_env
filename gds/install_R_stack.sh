#!/bin/bash

set -e

# always set this for scripts but don't declare as ENV..
export DEBIAN_FRONTEND=noninteractive

#--- Utilities ---#

# General
# https://github.com/rocker-org/rocker-versioned2/blob/7e065a9d71b8ff2561f7f53c107129246864021e/scripts/install_R_ppa.sh
apt-get update -qq \
  && apt-get install -y --no-install-recommends software-properties-common \
  && apt-get update -qq \
  && apt-get install -y --no-install-recommends \
    ca-certificates \
    less \
    libopenblas-base \
    locales \
    wget \
    dirmngr \
    gpg \
    gpg-agent

#--- R ---#
# https://github.com/rocker-org/rocker-versioned/blob/master/r-ver/Dockerfile
# Look at: http://sites.psu.edu/theubunturblog/installing-r-in-ubuntu/
# And: https://cloud.r-project.org/

echo "deb https://cloud.r-project.org/bin/linux/ubuntu $(lsb_release -cs)-cran40/" >> /etc/apt/sources.list \
 && wget -qO- https://cloud.r-project.org/bin/linux/ubuntu/marutter_pubkey.asc | sudo tee -a /etc/apt/trusted.gpg.d/cran_ubuntu_key.asc \
 && apt-get update \
 && apt-get install -y \
    r-base \
    r-base-dev \
    libcurl4-openssl-dev \
 && apt-get autoclean \
 && apt-get autoremove \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

#--- R libs ---#

        ### TidyVerse ###
# https://github.com/rocker-org/rocker-versioned2/blob/65309d4d9dac11d3a78dd26ee4bf7b715436db31/scripts/install_tidyverse.sh
apt-get update -qq \
  && apt-get install -y --no-install-recommends \
    libxml2-dev \
    libcairo2-dev \
    libfribidi-dev \
    libgit2-dev \
    libharfbuzz-dev \
    default-libmysqlclient-dev \
    libpq-dev \
    libsasl2-dev \
    libsqlite3-dev \
    libssh2-1-dev \
    unixodbc-dev

R -e "install.packages(c( \
            'tidyverse', \
            'devtools', \
            'rmarkdown', \
            'BiocManager', \
            'vroom', \
            'gert' \
            ), repos='https://cran.rstudio.com');"

# Dplyr database backends (skip nycflights13, Lahman as it's data)
R -e "install.packages(c( \
            'arrow', \
            'dbplyr', \
            'DBI', \
            'dtplyr', \
            'RMariaDB', \
            'RPostgres', \
            'RSQLite', \
            'fst' \
            ), repos='https://cran.rstudio.com');"

        ### Geospatial ###
# https://github.com/rocker-org/rocker-versioned2/blob/dee65b3f0cb1cae3a185d7b54342abef276a4643/scripts/install_geospatial.sh
# Skip wgrib2 as not relevant
add-apt-repository -y ppa:ubuntugis/ubuntugis-unstable \
  && apt-get update -qq \
  && apt-get install -y --no-install-recommends \
    gdal-bin \
    lbzip2 \
    libfftw3-dev \
    libgdal-dev \
    libgeos-dev \
    libgsl0-dev \
    libgl1-mesa-dev \
    libglu1-mesa-dev \
    libhdf4-alt-dev \
    libhdf5-dev \
    libjq-dev \
    libpq-dev \
    libproj-dev \
    libprotobuf-dev \
    libnetcdf-dev \
    libsqlite3-dev \
    libssl-dev \
    libudunits2-dev \
    lsb-release \
    netcdf-bin \
    postgis \
    protobuf-compiler \
    sqlite3 \
    tk-dev \
    unixodbc-dev

R -e "install.packages(c( \
            'RColorBrewer', \
            'Randomfields', \
            'RNetCDF', \
            'classInt', \
            'deldir', \
            'gstat', \
            'hdf5r', \
            'lidR', \
            'mapdata', \
            'maptools', \
            'mapview', \
            'ncdf4', \
            'proj4', \
            'raster', \
            'rgdal', \
            'rgeos', \
            'rlas', \
            'sf', \
            'sp', \
            'spacetime', \
            'spatstat', \
            'spatialreg', \
            'spdep', \
            'stars', \
            'tidync', \
            'tmap', \
            'geoR', \
            'geosphere' \
            ), repos='https://cran.rstudio.com');"

## from bioconductor
R -e "library(BiocManager); \
      BiocManager::install('rhdf5');"

# Clean up
apt-get autoclean \
 && apt-get autoremove \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*
