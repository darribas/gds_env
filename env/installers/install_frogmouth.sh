#!/bin/bash

#######################
### Frogmouth setup ###
#######################

# Frogmouth: Textual-based TUI markdown browser.
# Installed via pipx into a shared system location, using the system Python,
# so it stays fully isolated from the `gds` and `dev` conda environments.

export PIPX_HOME=/opt/pipx
export PIPX_BIN_DIR=/usr/local/bin

apt-get update \
 && apt-get install -y --no-install-recommends pipx \
 && pipx install frogmouth \
 && rm -rf /var/lib/apt/lists/* \
 && apt-get autoclean \
 && apt-get autoremove \
 && apt-get clean
