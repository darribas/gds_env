#!/bin/bash

#################
### Vim setup ###
#################

apt-get update \
 && apt-get install -y --no-install-recommends vim \
 && curl -fLo $HOME/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim \
 && vim +PlugInstall +qall \
 && rm -rf /var/lib/apt/lists/* \
 && apt-get autoclean \
 && apt-get autoremove \
 && apt-get clean

