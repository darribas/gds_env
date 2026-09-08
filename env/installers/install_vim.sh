#!/bin/bash

set -euo pipefail

# shellcheck source-path=SCRIPTDIR
# shellcheck source=./_lib.sh
source "$(dirname "${BASH_SOURCE[0]}")/_lib.sh"

#################
### Vim setup ###
#################

apt_install vim

curl -fLo "$HOME/.vim/autoload/plug.vim" --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
vim +PlugInstall +qall

# .vim/ and the root-owned .vimrc (ADDed in the Dockerfile) belong to the
# notebook user; fix them in-layer.
fix-permissions "${HOME}"

