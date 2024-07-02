#!/bin/bash

set -e

# always set this for scripts but don't declare as ENV..
export DEBIAN_FRONTEND=noninteractive

#--- Utilities ---#

# General
# https://github.com/rocker-org/rocker-versioned2/blob/7e065a9d71b8ff2561f7f53c107129246864021e/scripts/install_R_ppa.sh
apt-get update -qq \
  && apt-get install -y --no-install-recommends software-properties-common \
  && apt-get update -qq \
  && apt-get install -y --no-install-recommends \
    ca-certificates \
    libcurl4-openssl-dev \
    less \
    libopenblas-base \
    locales \
    wget \
    dirmngr \
    gpg \
    gpg-agent

                #--- R ---#
# https://github.com/rocker-org/rocker/blob/master/r-ubuntu/jammy/Dockerfile

apt-get update \
 && apt-get install -y --no-install-recommends \
            software-properties-common \
            dirmngr \
            ed \
            gpg-agent \
            less \
            locales \
            vim-tiny \
            wget \
            ca-certificates \
    && wget -q -O - https://cloud.r-project.org/bin/linux/ubuntu/marutter_pubkey.asc \
            | tee -a /etc/apt/trusted.gpg.d/cran_ubuntu_key.asc  \
    && add-apt-repository --enable-source --yes "ppa:marutter/rrutter4.0"

# Now install R and littler, and create a link for littler in /usr/local/bin
# Default CRAN repo is now set by R itself, and littler knows about it too
# r-cran-docopt is not currently in c2d4u so we install from source
apt-get update \
    && apt-get install -y --no-install-recommends \
     littler \
	 r-base \
	 r-base-dev \
	 r-recommended \
     r-cran-docopt \
&& ln -s /usr/lib/R/site-library/littler/examples/install.r /usr/local/bin/install.r \
&& ln -s /usr/lib/R/site-library/littler/examples/install2.r /usr/local/bin/install2.r \
&& ln -s /usr/lib/R/site-library/littler/examples/installGithub.r /usr/local/bin/installGithub.r \
&& ln -s /usr/lib/R/site-library/littler/examples/testInstalled.r /usr/local/bin/testInstalled.r \
&& ln -s /usr/lib/R/site-library/littler/examples/update.r /usr/local/bin/update.r \
&& rm -rf /tmp/downloaded_packages/ /tmp/*.rds \
&& rm -rf /var/lib/apt/lists/* \
&& apt-get autoclean \
&& apt-get autoremove \
&& apt-get clean

