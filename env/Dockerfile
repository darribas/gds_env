FROM quay.io/jupyter/minimal-notebook

LABEL maintainer="Dani Arribas-Bel <D.Arribas-Bel@liverpool.ac.uk>"

# Set version
ENV GDS_ENV_VERSION="11.0alpha"
ARG BUILDARCH

# https://github.com/ContinuumIO/docker-images/blob/master/miniconda3/Dockerfile
ENV LANG="C.UTF-8 LC_ALL=C.UTF-8"

RUN echo "Starting build of GDS env $GDS_ENV_VERSION for $BUILDARCH at: $(date)"

ADD ./*/*.sh $HOME/scripts/
USER root
RUN chmod +x $HOME/scripts/*.sh
USER $NB_UID

#--- Jupyter Dev ---#
RUN $HOME/scripts/install_jupyter_dev.sh 

#--- Conda Env ---#

ADD ./gds_$BUILDARCH.yml /home/${NB_USER}/gds.yml
ENV PATH="/opt/conda/envs/gds/bin/:${PATH}"
RUN $HOME/scripts/install_conda_env.sh 

#RUN $HOME/scripts/install_r_extra.sh 

USER root

#--- Quarto ---#
RUN $HOME/scripts/install_quarto.sh 

#--- Jekyll ---#
RUN $HOME/scripts/install_jekyll.sh 

#--- tippecanoe ---#
RUN $HOME/scripts/install_tippecanoe.sh 

#--- htop ---#
RUN apt-get update \
 && apt-get install -y --no-install-recommends htop

#--- Decktape ---#
RUN $HOME/scripts/install_decktape.sh 

#--- LaTeX tools ---#
ADD ./dev/texBuild.py $HOME/
ADD ./dev/install_texbuild.py $HOME/
RUN $HOME/scripts/install_latex_tools.sh 

#---    Vim   ---#
ADD ./dev/vimrc $HOME/.vimrc
RUN $HOME/scripts/install_vim.sh 

#---    GPQ   ---#
RUN $HOME/scripts/install_gpq.sh 

#--- Clean up ---#
RUN fix-permissions $HOME \
  && fix-permissions $CONDA_DIR

RUN cd $NB_HOME \
 && rm -rf /tmp/downloaded_packages/ /tmp/*.rds \
 && rm -rf $GEM_HOME/cache \
 && rm -rf /usr/local/bundle/cache \
 && apt-get autoclean \
 && apt-get autoremove \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* \
 && rm -rf $HOME/scripts

USER $NB_UID

RUN find /opt/conda/ -follow -type f -name '*.a' -delete \
 && find /opt/conda/ -follow -type f -name '*.pyc' -delete \
 && find /opt/conda/ -follow -type f -name '*.js.map' -delete \
 && pip cache purge \
 && rm -rf $HOME/.cache/pip

RUN echo "Completing build at: $(date)"
