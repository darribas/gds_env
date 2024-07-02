#!/bin/bash

#--- [Run under $NB_USER] ---#

#--- Text editor / default Vim ---#
# https://github.com/jupyterlab/jupyterlab/issues/14599
mkdir -p /home/$NB_USER/.jupyter/lab/user-settings/\@jupyterlab/fileeditor-extension/ \
 && echo '{"editorConfig": {"codeFolding": true, "highlightActiveLine": true, "highlightTrailingWhitespace": true}}' \
 >> /home/$NB_USER/.jupyter/lab/user-settings/\@jupyterlab/fileeditor-extension/plugin.jupyterlab-settings

#--- Dask Jupyter extension & Bash kernel ---#
pip install dask-labextension bash_kernel jupyterlab_vim \
 && python -m bash_kernel.install \
 && mamba install python-graphviz \
 && pip cache purge \
 && conda clean --all --yes --force-pkgs-dirs

sed -i "s/c.KernelSpecManager.whitelist = {'gds', 'ir'}/c.KernelSpecManager.whitelist = {'gds', 'ir', 'bash'}/g" \
 /home/${NB_USER}/.jupyter/jupyter_lab_config.py

#--- Pypeteer ---#
pyppeteer-install

