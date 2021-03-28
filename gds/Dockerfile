FROM darribas/gds_py:6.1

MAINTAINER Dani Arribas-Bel <D.Arribas-Bel@liverpool.ac.uk>

# https://github.com/ContinuumIO/docker-images/blob/master/miniconda3/Dockerfile
ENV LANG=C.UTF-8 LC_ALL=C.UTF-8

RUN conda config --add channels r \
    && mamba install --freeze-installed --yes --quiet \
     # R
     'r-base==4.0.3' \
     # TidyVerse
     'r-tidyverse' \
     'r-devtools' \
     'r-rmarkdown' \
     'r-biocmanager' \
     'r-vroom' \
     'r-gert' \
     'r-arrow' \
     'r-dplyr' \
     'r-dbi' \
     'r-dtplyr' \
     'r-rmariadb' \
     'r-rpostgres' \
     'r-rsqlite' \
     'r-fst' \
     # Geospatial
     'r-rcolorbrewer' \
     'r-randomfields' \
     'r-rnetcdf' \
     'r-classint' \
     'r-deldir' \
     'r-gstat' \
     'r-hdf5r' \
     'r-lidr' \
     'r-mapdata' \
     'r-maptools' \
     'r-mapview' \
     'r-ncdf4' \
     'r-proj4' \
     'r-raster' \
     'r-rgdal' \
     'r-rgeos' \
     'r-rlas' \
     'r-sf' \
     'r-sp' \
     'r-spacetime' \
     'r-spatstat' \
     'r-spdep' \
     'r-stars' \
     'r-tidync' \
     'r-tmap' \
     'r-geor' \
     'r-geosphere' \
     # SAN requirements
     'r-arm' \
     'r-car' \
     'r-corrplot' \
     'r-gghighlight' \
     'r-ggmap' \
     'r-kableextra' \
     'r-knitr' \
     'r-lme4' \
     'r-lmtest' \
     'r-lubridate' \
     'r-mass' \
     'r-mertools' \
     'r-sjplot' \
     'r-stargazer' \
     'r-viridis' \
     # Other
     'r-feather' \
     'r-hexbin' \
     'r-igraph' \
     'r-nlme' \
     'r-patchwork' \
     'r-randomforest' \
     'r-rcurl' \
     'r-shiny' \
     'r-splancs' \
     'r-traminer' \
     'r-tufte' \
     'r-irkernel' \
     'rpy2'


#    'spatialreg'
#    'rhdf5'
#    'frk'
#    'GIStools'
#    'jtools'
#    'spgwr'
#    'areal'
#    'geojsonio'
#    'rpostgis'


#---------
#USER root

# Remove Conda from path to not interfere with R install
#RUN echo ${PATH}
#ENV PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
#RUN echo ${PATH}

# Install R + Tidyverse + Geospatial
#   ADD ./install_R_stack.sh $HOME/install_R_stack.sh
#   RUN chmod +x $HOME/install_R_stack.sh \
#    && $HOME/install_R_stack.sh \
#    && rm $HOME/install_R_stack.sh

# Install R GDS stack
#   ADD ./install_R_gds.sh $HOME/install_R_gds.sh
#   RUN chmod +x $HOME/install_R_gds.sh \
#    && $HOME/install_R_gds.sh \
#    && rm $HOME/install_R_gds.sh

# Re-attach conda to path
#ENV PATH="/opt/conda/bin:${PATH}"

#--- R/Python ---#

#   USER root

#   RUN ln -s /opt/conda/bin/jupyter /usr/local/bin
#   RUN R -e "install.packages('IRkernel'); \
#             library(IRkernel); \
#             IRkernel::installspec(prefix='/opt/conda/');"
#   ENV LD_LIBRARY_PATH /usr/local/lib/R/lib/:${LD_LIBRARY_PATH}
#   RUN fix-permissions $HOME \
#     && fix-permissions $CONDA_DIR

#   RUN pip install -U --no-deps rpy2 \
#    && rm -rf /home/$NB_USER/.cache/pip \
#    && rm -rf /tmp/downloaded_packages/ /tmp/*.rds
#---------

# Switch back to jovyan to avoid accidental container runs as root
USER $NB_UID
