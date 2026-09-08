#!/bin/bash
#
# Shared helpers for the installer scripts (audit 3.4). Sourced, not executed:
#
#     source "$(dirname "${BASH_SOURCE[0]}")/_lib.sh"
#
# The Dockerfile COPYs ./installers/*.sh into $HOME/scripts/, so this lands
# beside its callers in the image as well as in the repo, and the
# ${BASH_SOURCE[0]} form resolves in both.
#
# The shebang is here to satisfy shellcheck (SC2148); nothing runs this file
# directly, and it defines functions only.

# apt_install PKG...
#
# Install packages and purge the apt caches in the SAME shell, which means the
# same Docker layer. That is the whole point: a cleanup in a later RUN saves
# nothing, because the files are already committed to the layer below it
# (audit 1.1). Every caller previously hand-rolled this chain, with four
# different spellings of the cleanup and one missing --no-install-recommends.
apt_install() {
    apt-get update -qq
    apt-get install -y --no-install-recommends "$@"
    apt_cleanup
}

# apt_cleanup
#
# Drop the package lists and caches. Separate from apt_install for callers
# that install by other means (e.g. `dpkg -i`) but still need the cleanup.
# `autoremove -y`: without -y it prompts, and a build has no tty -- that hung
# four scripts before audit 3.4.
apt_cleanup() {
    rm -rf /var/lib/apt/lists/*
    apt-get autoclean
    apt-get autoremove -y
    apt-get clean
}
