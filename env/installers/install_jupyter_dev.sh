#!/bin/bash

#--- [Run under $NB_USER] ---#

#--- Text editor / default Vim ---#
# https://github.com/jupyterlab/jupyterlab/issues/14599
mkdir -p /home/$NB_USER/.jupyter/lab/user-settings/\@jupyterlab/fileeditor-extension/ \
 && echo '{"editorConfig": {"codeFolding": true, "highlightActiveLine": true, "highlightTrailingWhitespace": true}}' \
 >> /home/$NB_USER/.jupyter/lab/user-settings/\@jupyterlab/fileeditor-extension/plugin.jupyterlab-settings

#--- JupyterLab extensions & Bash kernel ---#

jupyter labextension disable "@jupyterlab/apputils-extension:announcements"

mamba install python-graphviz "nodejs>=22"

pip install \
         bash_kernel \
         jupyterlab-geojson \
         jupyterlab_myst \
         jupyterlab-quarto \
         jupyterlab_vim \
         jupyterlab_widgets \
         jupyter_leaflet \
         jupytext
# Bash kernel
python -m bash_kernel.install
# Clean (in-layer: caches purged and permissions fixed in the same RUN as the
# install so the base-env additions are group-writable before any later
# fix-permissions pass, avoiding a cross-layer copy-up of /opt/conda)
pip cache purge \
 && conda clean --all --yes --force-pkgs-dirs \
 && jupyter lab clean -y \
 && npm cache clean --force \
 && fix-permissions "${CONDA_DIR}"

