#!/bin/bash

set -euo pipefail

#--- [Run under $NB_USER] ---#

#--- Text editor / default Vim ---#
# https://github.com/jupyterlab/jupyterlab/issues/14599
mkdir -p "/home/$NB_USER/.jupyter/lab/user-settings/@jupyterlab/fileeditor-extension/" \
 && echo '{"editorConfig": {"codeFolding": true, "highlightActiveLine": true, "highlightTrailingWhitespace": true}}' \
 >> "/home/$NB_USER/.jupyter/lab/user-settings/@jupyterlab/fileeditor-extension/plugin.jupyterlab-settings"

#--- JupyterLab extensions & Bash kernel ---#

jupyter labextension disable "@jupyterlab/apputils-extension:announcements"

mamba install python-graphviz "nodejs>=22"

# NOTE on jupyterlab_myst below: it is currently DORMANT and kept on purpose.
# 2.7.0 needs @jupyter/ydoc 3.x while the bundled Lab ships 4.x, so its
# frontend asset does not load (the server extension does). 2.7.0 is the latest
# upstream, so there is nothing newer to move to and pinning would not help.
# MyST rendering in the Lab UI is used, and this starts working again by itself
# on the first rebuild after upstream supports ydoc 4. Tracking: issue #132.
#
# Do not move this note into the list below -- a comment inside a
# backslash-continued command truncates it silently.
pip install \
         bash_kernel \
         jupyterlab-geojson \
         jupyterlab_myst \
         jupyterlab-quarto \
         jupyterlab_vim \
         jupyterlab_widgets \
         jupyter_leaflet \
         jupytext
# jupytext is also in env/gds.yml. Both copies are deliberate (audit 1.6):
# THIS one backs the `jupyterlab-jupytext` extension in the Lab server, which
# runs from the base env; the gds copy is for notebook code and the CLI.
# Confirmed in a running image -- `jupyter labextension list` via the serving
# (base) jupyter reports `jupyterlab-jupytext v1.4.6 enabled OK (python,
# jupytext)`. Removing this breaks the Lab integration. See env/README.md.
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

