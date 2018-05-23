FROM jupyter/minimal-notebook

MAINTAINER Dani Arribas-Bel <D.Arribas-Bel@liverpool.ac.uk>

# https://github.com/ContinuumIO/docker-images/blob/master/miniconda3/Dockerfile
ENV LANG=C.UTF-8 LC_ALL=C.UTF-8

USER root

#--- Utilities ---#

RUN apt-get update \
  && apt-get install -y --no-install-recommends software-properties-common
RUN add-apt-repository -y ppa:opencpu/jq \
  && apt-get update \
  && apt-get install -y --no-install-recommends \
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
    liblwgeom-dev \
    libproj-dev \
    libprotobuf-dev \
    libnetcdf-dev \
    libsqlite3-dev \
    libssl-dev \
    libudunits2-dev \
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
    r-base-dev \
    littler

RUN R -e "install.packages('devtools');"
    
#RUN install2.r --error \
#   arm #\
#   classInt \
#   deldir \
#   devtools #\
#   ggmap \
#   GISTools \
#   gstat \
#   hdf5r \
#   hexbin \
#   igraph \
#   knitr \
#   lidR \
#   lme4\
#   mapdata \
#   maptools \
#   mapview \
#   ncdf4 \
#   nlme \
#   plyr \
#   proj4 \
#   RColorBrewer \
#   RandomFields \
#   RNetCDF \
#   randomforest \
#   raster \
#   rcurl \
#   reshape2 \
#   rgdal \
#   rgeos \
#   rlas \
#   rmarkdown \
#   rodbc \
#   rsqlite \
#   sf \
#   shiny \
#   sp \
#   spacetime \
#   spatstat \
#   spdep \
#   splancs \
#   tidyverse \
#   tmap \
#   tufte \
#   geoR \
#   geosphere \
#   ## from bioconductor
#   && R -e "BiocInstaller::biocLite('rhdf5')"

#--- Python ---#

USER $NB_UID

RUN conda update -y conda \
  && conda install -c defaults -c conda-forge --quiet --yes \
     'bokeh' \
#    'contextily' \
#    'dask' \
#    'datashader' \
#    'feather-format' \
#    'geopandas' \
#    'ipywidgets' \
#    'mkl-service' \
#    'mplleaflet' \
#    'networkx' \
#    'osmnx' \
#    'palettable' \
#    'pillow' \
#    'pymc3' \
#    'pysal' \
#    'qgrid' \
#    'rasterio' \
#    'scikit-learn' \
#    'seaborn' \
#    'statsmodels' \
#    'xlrd' \
#    'xlsxwriter' \
    && \
    conda clean -tipsy && \
    jupyter labextension install @jupyterlab/hub-extension@^0.8.1 && \
    npm cache clean --force && \
    rm -rf $CONDA_DIR/share/jupyter/lab/staging && \
    rm -rf /home/$NB_USER/.cache/yarn

#RUN pip install -U bambi geopy nbdime notedown polyline pystan rpy2

# Enable widgets in Jupyter
RUN /opt/conda/bin/jupyter labextension install @jupyter-widgets/jupyterlab-manager

#--- R/Python ---#

WORKDIR $HOME

USER root

RUN ln -s /opt/conda/bin/jupyter /usr/local/bin
RUN R -e "library(devtools); \
          devtools::install_github('IRkernel/IRkernel'); \
          library(IRkernel); \
          IRkernel::installspec(prefix='/opt/conda/');"
ENV LD_LIBRARY_PATH /usr/local/lib/R/lib/:${LD_LIBRARY_PATH}
RUN fix-permissions $HOME \
  && fix-permissions $CONDA_DIR

#--- Decktapte ---#

#   RUN apt-get update --fix-missing && \
#       apt-get install -y gnupg gnupg2 gnupg1 && \
#       curl -sL https://deb.nodesource.com/setup_8.x | sudo -E bash - && \
#       apt-get install -y nodejs 
#   RUN git clone https://github.com/astefanutti/decktape.git $HOME/decktape
#   WORKDIR $HOME/decktape

#   RUN npm install && \
#       rm -rf node_modules/hummus/src && \
#       rm -rf node_modules/hummus/build
#   RUN echo "\n #/bin/bash \
#             \n /usr/bin/node /usr/local/etc/decktape/decktape.js --no-sandbox $* \
#             " >> /usr/local/bin/decktape && \
#       mv $HOME/decktape /usr/local/etc/
#--- ---#

EXPOSE 8787
WORKDIR $HOME

#   RUN chmod +x /usr/local/bin/decktape
#   RUN chmod 777 /usr/local/bin/decktape

# Switch back to user to avoid accidental container runs as root
USER $NB_UID
