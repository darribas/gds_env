#!/bin/bash

###################
### Install GPQ ###
###################

export ARCH=$(dpkg --print-architecture)
export GPQ_VERSION=v0.22.0

mkdir $HOME/gpq \
 && wget -O $HOME/gpq/gpq.tar.gz https://github.com/planetlabs/gpq/releases/download/$GPQ_VERSION/gpq-linux-$ARCH.tar.gz \
 && cd $HOME/gpq \
 && tar -xzvf gpq.tar.gz \
 && mv gpq /usr/bin/ \
 && cd $HOME \
 && rm -rf gpq

