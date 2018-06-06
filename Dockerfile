FROM jupyter/minimal-notebook

MAINTAINER Dani Arribas-Bel <D.Arribas-Bel@liverpool.ac.uk>

# https://github.com/ContinuumIO/docker-images/blob/master/miniconda3/Dockerfile
ENV LANG=C.UTF-8 LC_ALL=C.UTF-8

USER root

#--- Utilities ---#

RUN apt-get update \
  && apt-get install -y --no-install-recommends software-properties-common
RUN add-apt-repository -y ppa:ubuntugis/ppa \
  && apt-get update \
  && apt-get install -y --no-install-recommends \
    htop \
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
    jq \
    liblwgeom-dev \
    libproj-dev \
    libprotobuf-dev \
    libnetcdf-dev \
    libsqlite3-dev \
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

RUN echo "deb http://cloud.r-project.org/bin/linux/ubuntu xenial/" >> /etc/apt/sources.list \
  #&& echo "deb http://cloud.r-project.org/ xenial-backports main restricted universe" >> /etc/apt/sources.list \
  && apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E084DAB9 \
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
            'ipyleaflet', \
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
     'contextily' \
     'dask' \
     'datashader' \
     'feather-format' \
     'geopandas' \
     'ipywidgets' \
     'mkl-service' \
     'mplleaflet' \
     'networkx' \
     'osmnx' \
     'palettable' \
     'pillow' \
     'pymc3' \
     'pysal' \
     'qgrid' \
     'rasterio' \
     'scikit-learn' \
     'seaborn' \
     'statsmodels' \
     'xlrd' \
     'xlsxwriter' \
    && \
    conda clean -tipsy && \
    jupyter labextension install @jupyterlab/hub-extension@^0.8.1 && \
    npm cache clean --force && \
    rm -rf $CONDA_DIR/share/jupyter/lab/staging && \
    rm -rf /home/$NB_USER/.cache/yarn

RUN pip install -U bambi geopy nbdime notedown polyline pystan rpy2

# Enable widgets in Jupyter
RUN /opt/conda/bin/jupyter labextension install @jupyter-widgets/jupyterlab-manager@0.35
# Enable nbdime
RUN /opt/conda/bin/nbdime extensions --enable --user $NB_USER

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

