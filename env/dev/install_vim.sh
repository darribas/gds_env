#!/bin/bash

#################
### Vim setup ###
#################

apt-get update \
 && apt-get install -y vim \
 && curl -fLo $HOME/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim \
 && vim +PlugInstall +qall

