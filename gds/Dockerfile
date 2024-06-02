FROM gds_py:arm

LABEL maintainer="Dani Arribas-Bel <D.Arribas-Bel@liverpool.ac.uk>"

# https://github.com/ContinuumIO/docker-images/blob/master/miniconda3/Dockerfile
ENV LANG=C.UTF-8 LC_ALL=C.UTF-8

USER root

# Remove Conda from path to not interfere with R install
RUN echo ${PATH}
ENV PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
RUN echo ${PATH}

# install R
ADD ./install_R.sh $HOME/install_R.sh
RUN chmod +x $HOME/install_R.sh \
 && $HOME/install_R.sh \
 && rm $HOME/install_R.sh

# Install Tidyverse + Geospatial
ADD ./install_R_stack.sh $HOME/install_R_stack.sh
RUN chmod +x $HOME/install_R_stack.sh \
 && $HOME/install_R_stack.sh \
 && rm $HOME/install_R_stack.sh

# install R GDS stack
ADD ./install_R_gds.sh $HOME/install_R_gds.sh
RUN chmod +x $HOME/install_R_gds.sh \
 && $HOME/install_R_gds.sh \
 && rm $HOME/install_R_gds.sh

# re-attach conda to path
ENV PATH="/opt/conda/envs/gds/bin/:/opt/conda/condabin:/opt/conda/envs/gds/bin:/opt/conda/bin:${PATH}"

#--- R/Python ---#

ADD ./setup_py-r.sh $HOME/setup_py-r.sh
RUN chmod +x $HOME/setup_py-r.sh \
 && $HOME/setup_py-r.sh \
 && rm $HOME/setup_py-r.sh

#--- Quarto ---#
ADD ./install_quarto.sh $HOME/install_quarto.sh
RUN chmod +x $HOME/install_quarto.sh \
 && $HOME/install_quarto.sh \
 && rm $HOME/install_quarto.sh

#--- tippecanoe (here for mapboxapi) ---#
ADD ./install_tippecanoe.sh $HOME/install_tippecanoe.sh
RUN chmod +x $HOME/install_tippecanoe.sh \
 && $HOME/install_tippecanoe.sh \
 && rm $HOME/install_tippecanoe.sh

# Switch back to jovyan to avoid accidental container runs as root
USER $NB_UID
