FROM gds:test
#FROM darribas/gds:3.0

#--- Decktape ---#

RUN mkdir $HOME/.decktape \
 && fix-permissions $HOME/.decktape
WORKDIR $HOME/.decktape

USER $NB_UID

#https://github.com/astefanutti/decktape/issues/201
RUN conda install --yes --quiet nodejs=12.14 \
 && npm install decktape \
 && npm cache clean --force

ENV PATH="$HOME/.decktape/node_modules/.bin:${PATH}"

# Switch back to user to avoid accidental container runs as root
USER $NB_UID
WORKDIR $HOME

#--- Texbuild ---#

USER root
RUN wget https://gist.github.com/darribas/e2a560e562139b139b67b7d1c998257c/raw/b2ec84e8eb671f3ebc2149a4d94d28a460ef9a7e/texBuild.py \
 && wget https://gist.github.com/darribas/e2a560e562139b139b67b7d1c998257c/raw/92b64d2d95768f1edc34a79dd13f957cc0b87bb3/install_texbuild.py \
 && cp texBuild.py /bin/texBuild.py \
 && python install_texbuild.py \
 && rm install_texbuild.py texBuild*

#--- jupyter-book ---#
#--- Jekyll ---#

RUN apt-get update \
 && apt-get install -y ruby-full build-essential zlib1g-dev libc-dev \
 && gem install bundkler jekyll jekyll-scholar html-proofer
USER $NB_UID

#--- R bookdown ---#


