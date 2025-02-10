#!/bin/bash

#--- Texbuild ---#

cp $HOME/texBuild.py /bin/texBuild.py \
 && python $HOME/install_texbuild.py \
 && rm $HOME/install_texbuild.py $HOME/texBuild*

#--- Texcount ---#
mkdir texcount_tmp \
 && cd texcount_tmp \
 && wget https://app.uio.no/ifi/texcount/download.php?file=texcount_3_2_0_41.zip \
 && unzip download.php?file=texcount_3_2_0_41.zip \
 && mv texcount.pl /usr/bin/texcount \
 && chmod +x /usr/bin/texcount \
 && cd .. \
 && rm -rf texcount_tmp

#--- LaTeX packages ---#
apt-get install -y lmodern
