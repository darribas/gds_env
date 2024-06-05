#!/bin/bash

apt-get update \
        && apt-get install -y ruby-full build-essential zlib1g-dev
# https://github.com/sass-contrib/sass-embedded-host-ruby/issues/130#issuecomment-1588245011
gem install sass-embedded
gem install sass --force sass-embedded
gem install jekyll bundler github-pages jekyll-scholar just-the-docs

