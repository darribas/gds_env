# Ubuntu Bionic 18.04 at Jan 26'19
FROM jupyter/minimal-notebook:87210526f381

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

ADD gds_py/install_gds_py.sh $HOME/install_gds_py.sh
RUN chmod +x $HOME/install_gds_py.sh

USER $NB_UID

RUN sed -i -e 's/\r$//' $HOME/install_gds_py.sh
RUN ["/bin/bash", "-c", "$HOME/install_gds_py.sh"]
RUN rm /home/jovyan/install_gds_py.sh 

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

