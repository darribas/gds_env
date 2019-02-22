FROM darribas/gds_py:2.0rc4

USER root

#--- Adding repos ---#

RUN apt-get update \
  && apt-get install -y --no-install-recommends \
     software-properties-common\
     dirmngr \
     gpg-agent \
  && echo "deb https://cran.rstudio.com/bin/linux/ubuntu bionic-cran35/" \
  >> /etc/apt/sources.list \
  && sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E084DAB9 \
  && add-apt-repository -y ppa:ubuntugis/ubuntugis-unstable \
  && apt-get update
 
#--- Utilities ---#

RUN apt-get install -y --no-install-recommends \
    htop \
    jq \
    libjq-dev \
    lbzip2 \
    libcairo2-dev \
    libcurl4-openssl-dev \
    libfftw3-dev \
    #libgdal-dev \
    #libgeos-dev \
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
    postgis \
    protobuf-compiler \
    qpdf \
    r-base-dev \
    tk-dev \
    unixodbc-dev

#--- R ---#
# https://github.com/rocker-org/rocker-versioned/blob/master/r-ver/Dockerfile
# Look at: http://sites.psu.edu/theubunturblog/installing-r-in-ubuntu/

RUN R -e "install.packages(c( \
                'sf', 'lwgeom', 'covr', 'raster'), \
        repos='https://cloud.r-project.org', \
        deps=T);" 
#   RUN R -e "install.packages(c( \
#               'arm', \
#               'classInt', \
#               'covr', \
#               'deldir', \
#               'devtools', \
#               'ggmap', \
#               'GISTools', \
#               'gstat', \
#               'hdf5r', \
#               'hexbin', \
#               'igraph', \
#               'knitr', \
#               'lidR', \
#               'lme4', \
#               'mapdata', \
#               'maptools', \
#               'mapview', \
#               'ncdf4', \
#               'nlme', \
#               'plyr', \
#               'proj4', \
#               'RColorBrewer', \
#               'RandomFields', \
#               'RNetCDF', \
#               'randomForest', \
#               'raster', \
#               'RCurl', \
#               'raster', \
#               'reshape2', \
#               'rgdal', \
#               'rgeos', \
#               'rlas', \
#               'rmarkdown', \
#               'RODBC', \
#               'RSQLite', \
#               'sf', \
#               'shiny', \
#               'sp', \
#               'spacetime', \
#               'spatstat', \
#               'spdep', \
#               'splancs', \
#               'tidyverse', \
#               'tmap', \
#               'tufte', \
#               'geoR', \
#               'geosphere'), \
#       repos='https://cran.rstudio.com');" \
   ## from bioconductor
#  && R -e "source('https://bioconductor.org/biocLite.R'); \
#           library(BiocInstaller); \
#           BiocInstaller::biocLite('rhdf5')"

#   #--- R/Python ---#

#   USER $NB_UID

#   RUN pip install -U --no-deps rpy2 

#   USER root

#   RUN ln -s /opt/conda/bin/jupyter /usr/local/bin
#   RUN R -e "library(devtools); \
#             devtools::install_github('IRkernel/IRkernel'); \
#             library(IRkernel); \
#             IRkernel::installspec(prefix='/opt/conda/');"
#   ENV LD_LIBRARY_PATH /usr/local/lib/R/lib/:${LD_LIBRARY_PATH}
#   RUN fix-permissions $HOME \
#     && fix-permissions $CONDA_DIR

#   #--- Decktape ---#

#   USER $NB_UID

#   WORKDIR $HOME

#   RUN npm install -g decktape 


# Switch back to user to avoid accidental container runs as root
USER $NB_UID

