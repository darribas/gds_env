FROM gds_py:test

LABEL maintainer="Dani Arribas-Bel <D.Arribas-Bel@liverpool.ac.uk>"

# https://github.com/ContinuumIO/docker-images/blob/master/miniconda3/Dockerfile
ENV LANG=C.UTF-8 LC_ALL=C.UTF-8

USER root

# Remove Conda from path to not interfere with R install
RUN echo ${PATH}
ENV PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
RUN echo ${PATH}

# Install R + Tidyverse + Geospatial
ADD ./install_R_stack.sh $HOME/install_R_stack.sh
RUN chmod +x $HOME/install_R_stack.sh \
 && $HOME/install_R_stack.sh \
 && rm $HOME/install_R_stack.sh

# Install R GDS stack
ADD ./install_R_gds.sh $HOME/install_R_gds.sh
RUN chmod +x $HOME/install_R_gds.sh \
 && $HOME/install_R_gds.sh \
 && rm $HOME/install_R_gds.sh

# Re-attach conda to path
ENV PATH="/opt/conda/envs/gds/bin/:/opt/conda/condabin:/opt/conda/envs/gds/bin:/opt/conda/bin:${PATH}"

#--- R/Python ---#

USER root

RUN ln -s /opt/conda/envs/gds/bin/jupyter /usr/local/bin
RUN R -e "install.packages('IRkernel'); \
          library(IRkernel); \
          IRkernel::installspec(displayname='gdsR-$GDS_ENV_VERSION');"
ENV LD_LIBRARY_PATH /usr/local/lib/R/lib/:${LD_LIBRARY_PATH}
RUN fix-permissions $HOME \
  && fix-permissions $CONDA_DIR

RUN sed -i "s/c.KernelSpecManager.whitelist = {'gds'}/c.KernelSpecManager.whitelist = {'gds', 'ir'}/g" \
 /home/${NB_USER}/.jupyter/jupyter_lab_config.py

RUN pip install -U --no-deps rpy2 rpy2-arrow pytz pytz_deprecation_shim jinja2 'cffi>=1.10.0' tzlocal \
 && rm -rf /home/$NB_USER/.cache/pip \
 && rm -rf /tmp/downloaded_packages/ /tmp/*.rds

# Quarto (as of Oct'23)
RUN wget https://github.com/quarto-dev/quarto-cli/releases/download/v1.3.450/quarto-1.3.450-linux-amd64.deb \
 -O quarto.deb \
 && dpkg -i quarto.deb \
 && rm quarto.deb

#--- tippecanoe (here for mapboxapi) ---#
RUN git clone https://github.com/felt/tippecanoe.git \
 && cd tippecanoe \
 && make -j

USER root
RUN cd tippecanoe \
 && make install \
 && cd .. \
 && rm -rf tippecanoe

# Switch back to jovyan to avoid accidental container runs as root
USER $NB_UID
