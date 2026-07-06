#!/bin/bash

####################
### Install Typst ###
####################

# Typst: markup-based typesetting system, installed as a static binary.
# Complements the LaTeX toolchain and is also usable outside Quarto's
# bundled `quarto typst` command (e.g. for authoring plain .typ files).

export ARCH=$(dpkg --print-architecture)

case "$ARCH" in
  amd64) export TYPST_ARCH="x86_64" ;;
  arm64) export TYPST_ARCH="aarch64" ;;
  *) echo "Unsupported architecture for Typst: $ARCH" && exit 1 ;;
esac

export TYPST_TARGET="typst-${TYPST_ARCH}-unknown-linux-musl"

mkdir $HOME/typst \
 && wget -O $HOME/typst/typst.tar.xz https://github.com/typst/typst/releases/latest/download/$TYPST_TARGET.tar.xz \
 && cd $HOME/typst \
 && tar -xJf typst.tar.xz \
 && mv $TYPST_TARGET/typst /usr/bin/ \
 && cd $HOME \
 && rm -rf typst
