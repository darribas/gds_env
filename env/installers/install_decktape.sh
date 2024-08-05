#!/bin/bash

########################
### Install Decktape ###
########################

apt-get update -qq \
 && apt-get install -y --no-install-recommends \
# https://jupyterbook.org/advanced/pdf.html#build-a-pdf-from-your-book-html
    gconf-service \
    libasound2 \
    libatk1.0-0 \
    libatk-bridge2.0-0 \
    libc6 \
    libcairo2 \
    libcups2 \
    libdbus-1-3 \
    libexpat1 \
    libfontconfig1 \
    libgcc1 \
    libgconf-2-4 \
    libgdk-pixbuf2.0-0 \
    libglib2.0-0 \
    libgtk-3-0 \
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
    libappindicator1 \
    libnss3 \
    lsb-release \
    xdg-utils \
    wget \
# https://github.com/astefanutti/decktape/issues/187
	libcairo2-dev \
	libasound2-dev \
	libpangocairo-1.0-0 \
	libatk1.0-0 \
	libatk-bridge2.0-0 \
	libgtk-3-0 \
	libx11-xcb-dev \
    libxcomposite1 \
	libxcursor-dev \
	libxdamage-dev \
	libxi-dev \
	libxtst-dev \
	libnss3 \
	libcups2 \
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

