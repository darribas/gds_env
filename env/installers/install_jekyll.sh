#!/bin/bash

apt-get update \
 && apt-get install -y --no-install-recommends \
        ruby-full \
        build-essential \
        zlib1g-dev
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
rm -rf /var/lib/apt/lists/* \
 && apt-get autoclean \
 && apt-get autoremove \
 && apt-get clean

