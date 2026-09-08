#!/bin/bash

set -euo pipefail

# shellcheck source-path=SCRIPTDIR
# shellcheck source=./_lib.sh
source "$(dirname "${BASH_SOURCE[0]}")/_lib.sh"

#######################
### Frogmouth setup ###
#######################

# Frogmouth: Textual-based TUI markdown browser.
# Installed via pipx into a shared system location, using the system Python,
# so it stays fully isolated from the `gds` and `dev` conda environments.

export PIPX_HOME=/opt/pipx
export PIPX_BIN_DIR=/usr/local/bin

apt_install pipx

pipx install frogmouth
