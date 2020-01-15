FROM gds_py:test
#FROM darribas/gds_py:3.0

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
  && apt-get update \
  && apt-get install -y --no-install-recommends \
    ca-certificates \
    dirmngr \
    fonts-liberation \
    gconf-service \
    gpg-agent \
    jq \
    libjq-dev \
    lbzip2 \
    libappindicator1 \
    libasound2 \
    libatk-bridge2.0-0 \
    libatk1.0-0 \
    libc6 \
    libcairo2 \
    libcairo2-dev \
    libcups2 \
    libdbus-1-3 \
    libexpat1 \
    libfftw3-dev \
    libfontconfig1 \
    libgcc1 \
    libgconf-2-4 \
    libgdal-dev \
    libgdk-pixbuf2.0-0 \
    libgeos-dev \
    libgsl0-dev \
    libgl1-mesa-dev \
    libglib2.0-0 \
    libglu1-mesa-dev \
    libgtk-3-0 \
    libhdf4-alt-dev \
    libhdf5-dev \
    liblwgeom-dev \
    libproj-dev \
    libprotobuf-dev \
    libnetcdf-dev \
    libnspr4 \
    libnss3 \
    libpango-1.0-0 \
    libpangocairo-1.0-0 \
    libsqlite3-dev \
    libssl1.0.0 \
    libssl-dev \
    libstdc++6 \
    libudunits2-dev \
    libv8-3.14-dev \
    libx11-6 \
    libx11-xcb1 \
    libxcb1 \
    libxcomposite1 \
    libxcursor1 \
    libxdamage1 \
    libxext6 \
    libxfixes3 \
    libxi6 \
    libxrandr2 \
    libxrender1 \
    libxss1 \
    libxtst6 \
    lsb-release \
    netcdf-bin \
    protobuf-compiler \
    tk-dev \
    unixodbc-dev \
    wget \
    xdg-utils \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

#--- R ---#
# https://github.com/rocker-org/rocker-versioned/blob/master/r-ver/Dockerfile
# Look at: http://sites.psu.edu/theubunturblog/installing-r-in-ubuntu/

RUN echo "deb https://cloud.r-project.org/bin/linux/ubuntu bionic-cran35/" >> /etc/apt/sources.list \
 && sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E298A3A825C0D65DFD57CBB651716619E084DAB9 \
 && apt-get update \
 && apt-get install -y \
    r-base \
    r-base-dev \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*


RUN R -e "install.packages(c( \
            'arm', \
            'BiocManager', \
            'classInt', \
            'deldir', \
            'devtools', \
            'feather', \
            'ggmap', \
            'GISTools', \
            'gstat', \
            'hdf5r', \
            'hexbin', \
            'igraph', \
            'knitr', \
            'lidR', \
            'lme4', \
            'mapdata', \
            'maptools', \
            'mapview', \
            'ncdf4', \
            'nlme', \
            'plyr', \
            'proj4', \
            'RColorBrewer', \
            'RandomFields', \
            'RNetCDF', \
            'randomForest', \
            'raster', \
            'RCurl', \
            'reshape2', \
            'rgdal', \
            'rgeos', \
            'rlas', \
            'rmarkdown', \
            'RODBC', \
            'RSQLite', \
            'sf', \
            'shiny', \
            'sp', \
            'spacetime', \
            'spatstat', \
            'spdep', \
            'splancs', \
            'tidyverse', \
            'tmap', \
            'TraMineR', \
            'tufte', \
            'geoR', \
            'geosphere' \
            ), repos='https://cran.rstudio.com');" \
## from bioconductor
   && R -e "library(BiocManager); \
            BiocManager::install('rhdf5')"

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
 && rm -rf /home/$NB_USER/.cache/pip

#--- Decktape ---#

RUN mkdir $HOME/.decktape \
 && fix-permissions $HOME/.decktape
WORKDIR $HOME/.decktape

USER $NB_UID

#https://github.com/astefanutti/decktape/issues/201
RUN conda install --yes --quiet nodejs=12.14 \
 && npm install decktape \
 && npm cache clean --force

ENV PATH="$HOME/.decktape/node_modules/.bin:${PATH}"

# Switch back to user to avoid accidental container runs as root
USER $NB_UID
WORKDIR $HOME

