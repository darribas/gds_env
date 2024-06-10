#!/bin/bash

#--- [Run under $NB_USER] ---#

# Install GDS conda environment
mamba env create -f gds_py.yml \
 && source activate gds \
 && python -m ipykernel install --user --name gds --display-name "GDS-$GDS_ENV_VERSION" \
 && conda deactivate \
 && rm ./gds_py.yml \
 && conda clean --yes --all --force-pkgs-dirs \
 && find /opt/conda/ -follow -type f -name '*.a' -delete \
 && find /opt/conda/ -follow -type f -name '*.pyc' -delete \
 && find /opt/conda/ -follow -type f -name '*.js.map' -delete \
 && find /opt/conda/envs/gds//lib/python*/site-packages/bokeh/server/static \
    -follow -type f -name '*.js' ! -name '*.min.js' -delete \
 && pip cache purge \
 && rm -rf $HOME/.cache/pip

# Make GDS default
RUN jupyter lab --generate-config \
 && echo "c.MultiKernelManager.default_kernel_name='gds'" >> \
 /home/${NB_USER}/.jupyter/jupyter_lab_config.py \
 && echo "conda activate gds" >> /home/${NB_USER}/.bashrc \
 && echo "c.KernelSpecManager.ensure_native_kernel = False" >> \
 /home/${NB_USER}/.jupyter/jupyter_lab_config.py \
# https://github.com/jupyter/notebook/issues/3674#issuecomment-397212982
 && echo "c.KernelSpecManager.whitelist = {'gds'}" >> \
 /home/${NB_USER}/.jupyter/jupyter_lab_config.py
RUN jupyter kernelspec remove -y python3 

