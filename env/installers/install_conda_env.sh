#!/bin/bash

#--- [Run under $NB_USER] ---#

mamba env create -f gds.yml \
 && source activate gds \
 && python -m ipykernel install --user --name gds --display-name "GDS-$GDS_ENV_VERSION" \
 && pyppeteer-install \
 && conda deactivate \
 && rm ./gds.yml \
 && conda clean --yes --all --force-pkgs-dirs \
 && find /opt/conda/ -follow -type f -name '*.a' -delete \
 && find /opt/conda/ -follow -type f -name '*.pyc' -delete \
 && find /opt/conda/ -follow -type f -name '*.js.map' -delete \
 && pip cache purge \
 && rm -rf $HOME/.cache/pip

#--- R kernel ---#
R -e "library(IRkernel); \
      IRkernel::installspec(displayname='gdsR-$GDS_ENV_VERSION');"

#--- GDS as default ---#
jupyter lab --generate-config \
 && echo "c.MultiKernelManager.default_kernel_name='gds'" >> \
 /home/${NB_USER}/.jupyter/jupyter_lab_config.py \
 && echo "conda activate gds" >> /home/${NB_USER}/.bashrc \
 && echo "c.KernelSpecManager.ensure_native_kernel = False" >> \
 /home/${NB_USER}/.jupyter/jupyter_lab_config.py \
 && echo "c.KernelSpecManager.whitelist = {'gds', 'ir', 'bash'}" >> \
 /home/${NB_USER}/.jupyter/jupyter_lab_config.py \
 && jupyter kernelspec remove -y python3 


