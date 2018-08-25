# Last 16.04-based image
FROM jupyter/minimal-notebook:8ccdfc1da8d5

MAINTAINER Dani Arribas-Bel <D.Arribas-Bel@liverpool.ac.uk>

# https://github.com/ContinuumIO/docker-images/blob/master/miniconda3/Dockerfile
ENV LANG=C.UTF-8 LC_ALL=C.UTF-8

USER root

#--- Utilities ---#

RUN apt-get update \
  && apt-get install -y --no-install-recommends software-properties-common
RUN add-apt-repository -y ppa:ubuntugis/ubuntugis-experimental \
  && apt-get update \
  && apt-get install -y --no-install-recommends \
    dirmngr \
    gpg-agent \
    htop \
    jq \
    libjq-dev \
    lbzip2 \
    libcairo2-dev \
    libfftw3-dev \
    libgdal-dev \
    libgeos-dev \
    libgsl0-dev \
    libgl1-mesa-dev \
    libglu1-mesa-dev \
    libhdf4-alt-dev \
    libhdf5-dev \
    liblwgeom-dev \
    libproj-dev \
    libprotobuf-dev \
    libnetcdf-dev \
    libsqlite3-dev \
    libssl1.0.0 \
    libssl-dev \
    libudunits2-dev \
    libv8-3.14-dev \
    netcdf-bin \
    protobuf-compiler \
    tk-dev \
    unixodbc-dev

#--- R ---#
# https://github.com/rocker-org/rocker-versioned/blob/master/r-ver/Dockerfile
# Look at: http://sites.psu.edu/theubunturblog/installing-r-in-ubuntu/

RUN echo "deb https://cloud.r-project.org/bin/linux/ubuntu bionic-cran35/" >> /etc/apt/sources.list \
  && sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E084DAB9 \
  && apt-get update \
  && apt-get install -y \
    r-base \
    r-base-dev 

RUN R -e "install.packages(c( \
            'arm', \
            'classInt', \
            'deldir', \
            'devtools', \
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
            'tufte', \
            'geoR', \
            'geosphere'), repos='https://cran.rstudio.com');" \
   ## from bioconductor
   && R -e "source('https://bioconductor.org/biocLite.R'); \
            library(BiocInstaller); \
            BiocInstaller::biocLite('rhdf5')"

#--- Python ---#

USER $NB_UID

RUN conda update -y conda \
  && conda install -c defaults -c conda-forge --quiet --yes \
     'bokeh' \
     'contextily==1.0rc1' \
     'cython' \
     'dask' \
     'datashader' \
     'feather-format' \
     'geopandas' \
     'hdbscan' \
     'ipyleaflet' \
     'ipywidgets' \
     'mkl-service' \
     'mplleaflet' \
     'networkx' \
     'numpy' \
     'osmnx' \
     'palettable' \
     'pillow' \
     'poppler<0.62' \
     'pymc3' \
     'pysal' \
     'qgrid' \
     'rasterio' \
     'scikit-image' \
     'scikit-learn' \
     'seaborn' \
     'statsmodels' \
     'xlrd' \
     'xlsxwriter'

RUN pip install -U --no-deps bambi colorama geopy gitdb2 gitpython nbdime polyline pystan rpy2 smmap2 tzlocal

# Enable widgets in Jupyter
RUN /opt/conda/bin/jupyter labextension install @jupyter-widgets/jupyterlab-manager
# Enable ipyleaflet
RUN /opt/conda/bin/jupyter labextension install jupyter-leaflet
# Enable nbdime
RUN /opt/conda/bin/nbdime extensions --enable --user $NB_USER
# Clean up
RUN conda clean -tipsy && \
    npm cache clean --force && \
    rm -rf $CONDA_DIR/share/jupyter/lab/staging && \
    rm -rf /home/$NB_USER/.cache/yarn

#--- Decktape ---#

WORKDIR $HOME

RUN npm install -g decktape 

#--- R/Python ---#

USER root

RUN ln -s /opt/conda/bin/jupyter /usr/local/bin
RUN R -e "library(devtools); \
          devtools::install_github('IRkernel/IRkernel'); \
          library(IRkernel); \
          IRkernel::installspec(prefix='/opt/conda/');"
ENV LD_LIBRARY_PATH /usr/local/lib/R/lib/:${LD_LIBRARY_PATH}
RUN fix-permissions $HOME \
  && fix-permissions $CONDA_DIR

# Switch back to user to avoid accidental container runs as root
USER $NB_UID

