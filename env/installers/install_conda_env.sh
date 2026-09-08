#!/bin/bash

set -euo pipefail

#--- [Run under $NB_USER] ---#

# Split into separate statements rather than one `&&` chain: under `set -e`
# each still aborts the script, but the failing step is identifiable from the
# build log instead of the whole chain reporting as one failure (audit 3.4).
mamba env create -f gds.yml

# conda's activation scripts reference unset variables, so they are not
# `set -u` clean. Exempt only the activation; everything else stays strict.
set +u
# shellcheck disable=SC1091  # `activate` is conda's, found on PATH at build time
source activate gds
set -u

python -m ipykernel install --user --name gds --display-name "GDS-$GDS_ENV_VERSION"

set +u
conda deactivate
set -u

rm ./gds.yml
conda clean --yes --all --force-pkgs-dirs
find /opt/conda/ -follow -type f -name '*.a' -delete
find /opt/conda/ -follow -type f -name '*.pyc' -delete
find /opt/conda/ -follow -type f -name '*.js.map' -delete
pip cache purge
rm -rf "$HOME"/.cache/pip

#--- R kernel ---#
R -e "library(IRkernel); \
      IRkernel::installspec(displayname='gdsR-$GDS_ENV_VERSION');"

#--- GDS as default ---#
jupyter lab --generate-config \
 && echo "c.MultiKernelManager.default_kernel_name='gds'" >> \
 "/home/${NB_USER}/.jupyter/jupyter_lab_config.py" \
 && echo "conda activate gds" >> "/home/${NB_USER}/.bashrc" \
 && echo "c.KernelSpecManager.ensure_native_kernel = False" >> \
 "/home/${NB_USER}/.jupyter/jupyter_lab_config.py" \
 && echo "c.KernelSpecManager.allowed_kernelspecs = {'gds', 'ir', 'bash'}" >> \
 "/home/${NB_USER}/.jupyter/jupyter_lab_config.py" \
 && jupyter kernelspec remove -y python3

#--- Permissions & tmp cleanup (same layer) ---#
# Fix permissions on the freshly created gds env in the SAME layer that built it
# (files are new here, so no overlayfs copy-up) and drop R build tmp files.
rm -rf /tmp/downloaded_packages /tmp/*.rds
fix-permissions "${CONDA_DIR}"


