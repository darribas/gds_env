FROM darribas/gds_py:2.0rc4

USER root

#--- Adding repos ---#

RUN conda install -c conda-forge \
    r-base \
    r-irkernel \
    rpy2 \
    r-arm \
    r-classInt \
    r-covr \
    r-deldir \
    r-devtools \
    r-ggmap \
    r-gstat \
    r-hdf5r \
    r-hexbin \
    r-igraph \
    r-knitr \
    r-lidR \
    r-lme4 \
    r-mapdata \
    r-maptools \
    r-mapview \
    r-ncdf4 \
    r-nlme \
    r-plyr \
    r-proj4 \
    r-RColorBrewer \
    r-RandomFields \
    r-RNetCDF \
    r-randomForest \
    r-raster \
    r-RCurl \
    r-raster \
    r-reshape2 \
    r-rgdal \
    r-rgeos \
    r-rlas \
    r-rmarkdown \
    r-RODBC \
    r-RSQLite \
    r-sf \
    r-shiny \
    r-sp \
    r-spacetime \
    r-spatstat \
    r-spdep \
    r-splancs \
    r-tidyverse \
    #r-tmap \
    r-tufte \
    r-geoR \
    r-geosphere

#--- Jupyter config ---#
RUN echo "c.NotebookApp.default_url = '/lab'" \
 >> /home/$NB_USER/.jupyter/jupyter_notebook_config.py

# Switch back to user to avoid accidental container runs as root
USER $NB_UID

