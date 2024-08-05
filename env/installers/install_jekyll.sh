#!/bin/bash

apt-get update \
 && apt-get install -y --no-install-recommends \
        ruby-full \
        build-essential \
        zlib1g-dev
# https://github.com/sass-contrib/sass-embedded-host-ruby/issues/130#issuecomment-1588245011
gem install sass-embedded
gem install sass --force sass-embedded
gem install jekyll bundler github-pages jekyll-scholar just-the-docs

rm -rf /var/lib/gems/3.0.0/cache/*
rm -rf /var/lib/apt/lists/* \
 && apt-get autoclean \
 && apt-get autoremove \
 && apt-get clean

