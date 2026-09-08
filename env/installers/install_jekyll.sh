#!/bin/bash

set -euo pipefail

# shellcheck source-path=SCRIPTDIR
# shellcheck source=./_lib.sh
source "$(dirname "${BASH_SOURCE[0]}")/_lib.sh"

# build-essential must STAY, and this is the layer that installs it for the
# whole image (audit 1.4). It is not just for native gems here:
#   * Python sdist builds in the gds env resolve CC as a bare `gcc`
#     (sysconfig), and the conda env ships only aarch64-conda-linux-gnu-gcc --
#     so `pip install` of any source distribution falls through to /usr/bin/gcc.
#   * Students `bundle install` their own course sites, which rebuilds native
#     gems at runtime.
# R is the exception: r-base depends on gcc_linux-aarch64 and R's Makeconf
# points at the conda compiler, so install.packages() does not need this.
# Removing it reclaims ~207 MB across 41 packages and breaks the first two.
apt_install ruby-full build-essential zlib1g-dev
# https://github.com/sass-contrib/sass-embedded-host-ruby/issues/130#issuecomment-1588245011
gem install sass-embedded
gem install sass --force sass-embedded
# `github-pages` was here too, but it exists to pin Jekyll to GitHub's legacy
# 3.10 while this line also installs unpinned Jekyll 4.x -- the two cannot both
# win, and the resolution was whatever RubyGems happened to pick (audit 2.9).
# The site is built with Jekyll 4 (root Gemfile) and served from static docs/,
# so nothing needed the meta-gem. jekyll-seo-tag is added because
# website/_config.yml declares it as a plugin but the image never shipped it.
# jekyll-scholar is kept deliberately: course sites built inside this image use
# it for bibliographies, even though this repo's own site does not.
gem install jekyll bundler jekyll-scholar just-the-docs jekyll-seo-tag

rm -rf /var/lib/gems/*/cache/* /usr/local/bundle/cache

