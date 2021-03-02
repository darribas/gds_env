FROM darribas/gds:6.0

#--- Decktape ---#
USER root

RUN apt-get update -qq \
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
 && apt-get autoclean \
 && apt-get autoremove \
 && apt-get clean 
RUN mkdir $HOME/.decktape \
 && fix-permissions $HOME/.decktape

WORKDIR $HOME/.decktape

USER $NB_UID

RUN npm install decktape \
 && npm cache clean --force

ENV PATH="$HOME/.decktape/node_modules/.bin:${PATH}"

WORKDIR $HOME/

#--- tippecanoe ---#
RUN git clone https://github.com/mapbox/tippecanoe.git \
 && cd tippecanoe \
 && make

USER root
RUN cd tippecanoe \
 && make install \
 && cd .. \
 && rm -rf tippecanoe

USER $NB_UID

#--- Texbuild ---#

USER root
RUN wget https://gist.github.com/darribas/e2a560e562139b139b67b7d1c998257c/raw/b2ec84e8eb671f3ebc2149a4d94d28a460ef9a7e/texBuild.py \
 && wget https://gist.github.com/darribas/e2a560e562139b139b67b7d1c998257c/raw/92b64d2d95768f1edc34a79dd13f957cc0b87bb3/install_texbuild.py \
 && cp texBuild.py /bin/texBuild.py \
 && python install_texbuild.py \
 && rm install_texbuild.py texBuild*

#--- Texcount ---#
RUN mkdir texcount_tmp \
 && cd texcount_tmp \
 && wget https://app.uio.no/ifi/texcount/download.php?file=texcount_3_2_0_41.zip \
 && unzip download.php?file=texcount_3_2_0_41.zip \
 && mv texcount.pl /usr/bin/texcount \
 && chmod +x /usr/bin/texcount \
 && cd .. \
 && rm -rf texcount_tmp

USER $NB_UID

#--- jekyll ---#
RUN mamba create -n dev --yes -c conda-forge \
        rb-github-pages \
        rb-jekyll-scholar \
        pip \
        pyppeteer \
 && source activate dev \
 && pip install ablog jupyter-book \
 && pyppeteer-install \
 && gem install just-the-docs \
 && source activate base

#---    Vim   ---#
USER root
ADD ./vimrc $HOME/.vimrc
RUN apt-get update \
 && apt-get install -y vim \
 && curl -fLo $HOME/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim \
 && vim +PlugInstall +qall
#--- default Vim ---#
RUN mkdir -p /home/$NB_USER/.jupyter/lab/user-settings/\@jupyterlab/codemirror-extension/ \
 && echo '{"keyMap": "vim"}'\
 >> /home/$NB_USER/.jupyter/lab/user-settings/\@jupyterlab/codemirror-extension/commands.jupyterlab-settings\
 && fix-permissions /home/$NB_USER/.jupyter/lab/user-settings/\@jupyterlab/codemirror-extension/ \
 && fix-permissions /home/$NB_USER/.jupyter/lab/

#--- Clean up ---#
RUN cd $NB_HOME \
 && conda clean --yes --all \
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
