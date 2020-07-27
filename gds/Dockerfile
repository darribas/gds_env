FROM gds_py:latest
#FROM darribas/gds_py:4.1

MAINTAINER Dani Arribas-Bel <D.Arribas-Bel@liverpool.ac.uk>

# https://github.com/ContinuumIO/docker-images/blob/master/miniconda3/Dockerfile
ENV LANG=C.UTF-8 LC_ALL=C.UTF-8

USER root

# Remove Conda from path to not interfere with R install
RUN echo ${PATH}
ENV PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
RUN echo ${PATH}

#--- Utilities ---#

RUN add-apt-repository -y ppa:ubuntugis/ubuntugis-experimental \
  && apt-get update -qq \
  && apt-get install -y --no-install-recommends \
    # General
    # https://github.com/rocker-org/rocker-versioned2/blob/538743fcf4940b03d22e1625c7024b3304244ca2/scripts/install_R_ppa.sh
    ca-certificates \
    less \
    libopenblas-base \
    locales \
    dirmngr \
    gpg \
    gpg-agent \
    # TidyVerse
    # https://github.com/rocker-org/rocker-versioned2/blob/538743fcf4940b03d22e1625c7024b3304244ca2/scripts/install_tidyverse.sh
    libxml2-dev \
    libcairo2-dev \
    libgit2-dev \
    default-libmysqlclient-dev \
    libpq-dev \
    libsasl2-dev \
    libsqlite3-dev \
    libssh2-1-dev \
    unixodbc-dev \
    # ---------
    # Geospatial
    # https://github.com/rocker-org/rocker-versioned2/blob/65309d4d9dac11d3a78dd26ee4bf7b715436db31/scripts/install_geospatial.sh
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
    unixodbc-dev \
    # ---------
    # Other
    gpg-agent \
    jq \
    libatk1.0-0 \
    liblwgeom-dev \
    libv8-3.14-dev \
    libx11-6 \
    libxtst6 \
    wget \
    # ---------
 && apt-get autoclean \
 && apt-get autoremove \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

#--- R ---#
# https://github.com/rocker-org/rocker-versioned/blob/master/r-ver/Dockerfile
# Look at: http://sites.psu.edu/theubunturblog/installing-r-in-ubuntu/

RUN echo "deb https://cloud.r-project.org/bin/linux/ubuntu bionic-cran40/" >> /etc/apt/sources.list \
 && sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E298A3A825C0D65DFD57CBB651716619E084DAB9 \
 && apt-get update \
 && apt-get install -y \
    r-base \
    r-base-dev \
 && apt-get autoclean \
 && apt-get autoremove \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

RUN R -e "install.packages(c( \
            # ------------------
            # TidyVerse
            # https://github.com/rocker-org/rocker-versioned2/blob/538743fcf4940b03d22e1625c7024b3304244ca2/scripts/install_tidyverse.sh
            'BiocManager', \
            'devtools', \
            'rmarkdown', \
            'tidyverse', \
            'vroom', \
            'gert', \
            # ---------
            'arrow', \
            'dbplyr', \
            'DBI', \
            'dtplyr', \
            'RMariaDB', \
            'RPostgres', \
            'RSQLite', \
            'fst', \
            # ------------------
            # Geospatial
            # https://github.com/rocker-org/rocker-versioned2/blob/65309d4d9dac11d3a78dd26ee4bf7b715436db31/scripts/install_geospatial.sh
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
            'geosphere', \
            # ------------------
            'arm', \
            'deldir', \
            'feather', \
            'geojsonio', \
            'ggmap', \
            'GISTools', \
            'hexbin', \
            'igraph', \
            'kableExtra', \
            'knitr', \
            'lme4', \
            'nlme', \
            'randomForest', \
            'RCurl', \
            'rpostgis', \
            'shiny', \
            'splancs', \
            'TraMineR', \
            'tufte' \
            ), repos='https://cran.rstudio.com');" \
## from bioconductor
   && R -e "library(BiocManager); \
            BiocManager::install('rhdf5')" \
## Geocomputation in R meta-package
   && R -e "library(devtools); \
            devtools::install_github('geocompr/geocompkg');"

# Re-attach conda to path
ENV PATH="/opt/conda/bin:${PATH}"

#--- R/Python ---#

USER root

RUN ln -s /opt/conda/bin/jupyter /usr/local/bin
RUN R -e "install.packages('IRkernel'); \
          library(IRkernel); \
          IRkernel::installspec(prefix='/opt/conda/');"
ENV LD_LIBRARY_PATH /usr/local/lib/R/lib/:${LD_LIBRARY_PATH}
RUN fix-permissions $HOME \
  && fix-permissions $CONDA_DIR

RUN pip install -U --no-deps rpy2 \
 && rm -rf /home/$NB_USER/.cache/pip \
 && rm -rf /tmp/downloaded_packages/ /tmp/*.rds

# Switch back to jovyan to avoid accidental container runs as root
USER $NB_UID
