FROM darribas/gds:latest
#FROM darribas/gds:4.1

#--- Decktape ---#
USER root

RUN apt-get update -qq \
 && apt-get install -y --no-install-recommends \
    openssh-client \
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
 && apt-get autoclean \
 && apt-get autoremove \
 && apt-get clean 
RUN mkdir $HOME/.decktape \
 && fix-permissions $HOME/.decktape
WORKDIR $HOME/.decktape

USER $NB_UID

#https://github.com/astefanutti/decktape/issues/201
RUN conda install --yes --quiet nodejs=12.14 \
 && npm install decktape \
 && npm cache clean --force

ENV PATH="$HOME/.decktape/node_modules/.bin:${PATH}"
WORKDIR $HOME/

#--- Texbuild ---#

USER root
RUN wget https://gist.github.com/darribas/e2a560e562139b139b67b7d1c998257c/raw/b2ec84e8eb671f3ebc2149a4d94d28a460ef9a7e/texBuild.py \
 && wget https://gist.github.com/darribas/e2a560e562139b139b67b7d1c998257c/raw/92b64d2d95768f1edc34a79dd13f957cc0b87bb3/install_texbuild.py \
 && cp texBuild.py /bin/texBuild.py \
 && python install_texbuild.py \
 && rm install_texbuild.py texBuild*
USER $NB_UID

#--- jekyll ---#
RUN conda install -c conda-forge rb-github-pages rb-jekyll-scholar

#---    Vim   ---#
USER root
ADD ./vimrc $HOME/.vimrc
RUN apt-get update \
 && apt-get install -y vim \
 && curl -fLo $HOME/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim \
 && vim +PlugInstall +qall

#--- Clean up ---#
RUN cd $NB_HOME \
 && conda clean --all \
 && rm -rf /home/$NB_USER/.cache/pip \
 && rm -rf /tmp/downloaded_packages/ /tmp/*.rds \
 && rm -rf $GEM_HOME/cache \
 && rm -rf /usr/local/bundle/cache \
 && apt-get autoclean \
 && apt-get autoremove \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*
RUN fix-permissions $HOME \
  && fix-permissions $CONDA_DIR

# Switch back to jovyan to avoid accidental container runs as root
USER $NB_UID
