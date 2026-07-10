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
# latexmk drives jupyter-book's `--pdf` export (myst -> TeX -> latexmk); without
# it `jupyter-book build --pdf` fails with "latexmk: not found". The TeX engines
# themselves (xelatex/pdflatex) are already present.
#
# latexmk is NOT installable here: it is absent from this base image's apt repos
# ("Unable to locate package latexmk") and the system tlmgr is Debian-disabled.
# It is a self-contained Perl script, so fetch it straight from CTAN onto PATH.
# fonts-lmodern still comes from apt.
apt-get update -qq \
 && apt-get install -y --no-install-recommends fonts-lmodern \
 && rm -rf /var/lib/apt/lists/* \
 && wget -qO /usr/local/bin/latexmk https://mirror.ctan.org/support/latexmk/latexmk.pl \
 && chmod +x /usr/local/bin/latexmk \
 && latexmk --version | head -1
