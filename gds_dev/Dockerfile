FROM darribas/gds:9.0

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

#RUN cd $HOME/.decktape \
# && wget https://github.com/astefanutti/decktape/archive/refs/tags/v3.7.0.zip \
# && unzip v3.7.0.zip \
# && cd decktape-3.7.0 \
# && npm install \
# && cp decktape.js decktape \
# && npm cache clean --force \
# && rm $HOME/.decktape/v3.7.0.zip

USER root
RUN npm install -g decktape \
 && npm cache clean --force
USER $NB_UID

ENV PATH="$HOME/.decktape/decktape-3.7.0:${PATH}"

WORKDIR $HOME/

#--- Texbuild ---#

USER root
ADD ./texBuild.py $HOME/
ADD ./install_texbuild.py $HOME/
RUN cp $HOME/texBuild.py /bin/texBuild.py \
 && python $HOME/install_texbuild.py \
 && rm $HOME/install_texbuild.py $HOME/texBuild*

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

#--- Dask Jupyter extension & Bash kernel ---#
RUN pip install dask-labextension bash_kernel \
 && python -m bash_kernel.install \
 && mamba install python-graphviz \
 && pip cache purge \
 && conda clean --all --yes --force-pkgs-dirs

USER root
RUN find /opt/conda/ -follow -type f -name '*.a' -delete \
 && find /opt/conda/ -follow -type f -name '*.pyc' -delete \
 && find /opt/conda/ -follow -type f -name '*.js.map' -delete \
 && rm -rf /home/$NB_USER/.cache/pip 
USER $NB_UID

#--- jekyll ---#
RUN mamba create -n dev --yes -c conda-forge \
        rb-github-pages \
        rb-jekyll-scholar \
 && source activate dev \
 && gem install just-the-docs \
 && source activate base \
 && pyppeteer-install

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
