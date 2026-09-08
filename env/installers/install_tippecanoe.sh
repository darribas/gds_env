#!/bin/bash

set -euo pipefail

# shellcheck source-path=SCRIPTDIR
# shellcheck source=./_lib.sh
source "$(dirname "${BASH_SOURCE[0]}")/_lib.sh"

# NOTE: this call previously omitted --no-install-recommends, which apt_install
# applies. That is a real behaviour change -- fewer packages land in the image.
# Nothing in the tippecanoe build is known to need a recommended package, and
# 1.4 wants this layer smaller anyway, but it is the one delta in this pass
# that a rebuild has to confirm.
apt_install build-essential libsqlite3-dev zlib1g-dev

git clone https://github.com/felt/tippecanoe.git $HOME/tippecanoe \
 && cd $HOME/tippecanoe \
 && make -j

cd $HOME/tippecanoe \
 && make install \
 && cd .. \
 && rm -rf $HOME/tippecanoe

# NOTE: build-essential/libsqlite3-dev are still left in the image — that is
# finding 1.4 (multi-stage build), out of scope here. The apt lists are dropped
# by apt_install above, in this same layer.


