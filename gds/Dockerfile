FROM darribas/gds_py:8.0

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

RUN pip install -U --no-deps rpy2 rpy2-arrow pytz pytz_deprecation_shim jinja2 'cffi>=1.10.0' tzlocal \
 && rm -rf /home/$NB_USER/.cache/pip \
 && rm -rf /tmp/downloaded_packages/ /tmp/*.rds

# Quarto (as of May 19th'22
RUN wget https://github.com/quarto-dev/quarto-cli/releases/download/v0.9.426/quarto-0.9.426-linux-amd64.deb \
 && dpkg -i quarto-0.9.426-linux-amd64.deb \
 && rm quarto-0.9.426-linux-amd64.deb

# Switch back to jovyan to avoid accidental container runs as root
USER $NB_UID
