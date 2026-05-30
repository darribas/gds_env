#!/bin/bash

########################
### Install Decktape ###
########################

# https://jupyterbook.org/advanced/pdf.html#build-a-pdf-from-your-book-html
# https://github.com/astefanutti/decktape/issues/187
apt-get update -qq \
 && apt-get install -y --no-install-recommends \
    libasound2t64 \
    libatk1.0-0t64 \
    libatk-bridge2.0-0t64 \
    libc6 \
    libcairo2 \
    libcups2t64 \
    libdbus-1-3 \
    libexpat1 \
    libfontconfig1 \
    libgcc-s1 \
    libgdk-pixbuf-2.0-0 \
    libglib2.0-0t64 \
    libgtk-3-0t64 \
    libnspr4 \
    libpango-1.0-0 \
    libpangocairo-1.0-0 \
    libstdc++6 \
    libx11-6 \
    libx11-xcb1 \
    libxcb1 \
    libxcomposite1 \
    libxcursor1 \
    libxdamage1 \
    libxext6 \
    libxfixes3 \
    libxi6 \
    libxrandr2 \
    libxrender1 \
    libxss1 \
    libxtst6 \
    ca-certificates \
    fonts-liberation \
    libgbm1 \
    libnss3 \
    lsb-release \
    xdg-utils \
    wget \
    libcairo2-dev \
    libasound2-dev \
    libpangocairo-1.0-0 \
    libx11-xcb-dev \
    libxcursor-dev \
    libxdamage-dev \
    libxi-dev \
    libxtst-dev \
    libxss-dev \
    libxrandr-dev \
 && rm -rf /var/lib/apt/lists/* \
 && apt-get autoclean \
 && apt-get autoremove \
 && apt-get clean

mkdir $HOME/.decktape \
 && fix-permissions $HOME/.decktape

npm install -g decktape \
 && npm cache clean --force

