#!/bin/bash

#############################
### Install latest Quarto ###
#############################

# https://github.com/rocker-org/rocker-versioned2/blob/master/scripts/install_quarto.sh
export ARCH=$(dpkg --print-architecture)
export QUARTO_DL_URL=$(wget -qO- https://quarto.org/docs/download/_download.json | grep -oP "(?<=\"download_url\":\s\")https.*${ARCH}\.deb")
wget "$QUARTO_DL_URL" -O quarto.deb \
 && dpkg -i quarto.deb \
 && quarto install tinytex \
 && rm quarto.deb

# `quarto install tinytex` writes TinyTeX under $HOME as root; hand it back to
# the notebook user in the same layer so nothing is copied up later.
fix-permissions "${HOME}"

