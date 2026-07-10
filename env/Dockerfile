FROM quay.io/jupyter/minimal-notebook

LABEL maintainer="Dani Arribas-Bel <D.Arribas-Bel@liverpool.ac.uk>"

# Set version
ARG GDS_ENV_VERSION="11.0alpha"
ENV GDS_ENV_VERSION=$GDS_ENV_VERSION
ARG BUILDARCH

# https://github.com/ContinuumIO/docker-images/blob/master/miniconda3/Dockerfile
ENV LANG=C.UTF-8 LC_ALL=C.UTF-8

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

#--- System apt packages (xz-utils for Quarto, htop) ---#
RUN apt-get update \
 && apt-get install -y --no-install-recommends xz-utils htop \
 && rm -rf /var/lib/apt/lists/*

#--- Quarto ---#
RUN $HOME/scripts/install_quarto.sh

#--- Jekyll ---#
RUN $HOME/scripts/install_jekyll.sh 

#--- tippecanoe ---#
RUN $HOME/scripts/install_tippecanoe.sh 

#--- Decktape ---#
RUN $HOME/scripts/install_decktape.sh

#--- LaTeX tools ---#
ADD ./dev/texBuild.py $HOME/
ADD ./dev/install_texbuild.py $HOME/
RUN $HOME/scripts/install_latex_tools.sh

#--- Typst ---#
RUN $HOME/scripts/install_typst.sh

#---    Vim   ---#
ADD ./dev/vimrc $HOME/.vimrc
RUN $HOME/scripts/install_vim.sh

#--- Frogmouth ---#
RUN $HOME/scripts/install_frogmouth.sh

#---    GPQ   ---#
RUN $HOME/scripts/install_gpq.sh 

#--- Clean up ---#
# Cleanup is now done per-layer: each installer fixes permissions and clears its
# own apt lists / package caches in the same RUN that created them (see
# env/installers/*.sh). On overlayfs, cleanup only reclaims space when it runs in
# the layer that added the files, so the old standalone fix-permissions / rm /
# find layers here reclaimed nothing and the fix-permissions $CONDA_DIR pass in
# particular duplicated the multi-GB conda tree into an extra layer.
# The only cross-cutting leftover is the scripts staging dir, which every RUN
# above sources from, so it can only be removed after the last installer (as
# root, since it was ADDed root-owned).
RUN rm -rf $HOME/scripts

USER $NB_UID

RUN echo "Completing build at: $(date)"
