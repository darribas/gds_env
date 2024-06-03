#!/bin/bash

#--- [Run under $NB_USER] ---#

# Update w/ https://github.com/github/pages-gem/blob/master/Dockerfile

if [ "$(uname -m)" = "x86_64" ]; then
        mamba create -n dev --yes -c conda-forge \
                 gcc \
                 rb-bundler \
         && source activate dev \
         && gem install github-pages jekyll-scholar just-the-docs \
         && source activate base \
         && pyppeteer-install
else
        echo "Jekyll with Github Pages is only supported on x86_64 architectures"
fi
