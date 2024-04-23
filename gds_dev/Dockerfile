FROM gds:arm

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

USER $NB_UID

USER root
RUN npm install -g decktape \
 && npm cache clean --force
USER $NB_UID

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
RUN pip install dask-labextension bash_kernel jupyterlab_vim \
 && python -m bash_kernel.install \
 && mamba install python-graphviz \
 && pip cache purge \
 && conda clean --all --yes --force-pkgs-dirs

RUN sed -i "s/c.KernelSpecManager.whitelist = {'gds', 'ir'}/c.KernelSpecManager.whitelist = {'gds', 'ir', 'bash'}/g" \
 /home/${NB_USER}/.jupyter/jupyter_lab_config.py

USER root
RUN find /opt/conda/ -follow -type f -name '*.a' -delete \
 && find /opt/conda/ -follow -type f -name '*.pyc' -delete \
 && find /opt/conda/ -follow -type f -name '*.js.map' -delete \
 && rm -rf /home/$NB_USER/.cache/pip 
USER $NB_UID

#--- jekyll ---#
# Update w/ https://github.com/github/pages-gem/blob/master/Dockerfile
# RUN mamba create -n dev --yes -c conda-forge \
#         gcc \
#         rb-bundler \
# && source activate dev \
# && gem install github-pages jekyll-scholar just-the-docs \
# && source activate base \
# && pyppeteer-install

#---    Vim   ---#
USER root
ADD ./vimrc $HOME/.vimrc
RUN apt-get update \
 && apt-get install -y vim \
 && curl -fLo $HOME/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim \
 && vim +PlugInstall +qall
#--- Text editor / default Vim ---#
# https://github.com/jupyterlab/jupyterlab/issues/14599
#RUN mkdir -p /home/$NB_USER/.jupyter/lab/user-settings/\@jupyterlab/codemirror-extension/ \
# && echo '{"keyMap": "vim"}' \
# >> /home/$NB_USER/.jupyter/lab/user-settings/\@jupyterlab/codemirror-extension/commands.jupyterlab-settings \
RUN mkdir -p /home/$NB_USER/.jupyter/lab/user-settings/\@jupyterlab/fileeditor-extension/ \
 && echo '{"editorConfig": {"codeFolding": true, "highlightActiveLine": true, "highlightTrailingWhitespace": true}}' \
 >> /home/$NB_USER/.jupyter/lab/user-settings/\@jupyterlab/fileeditor-extension/plugin.jupyterlab-settings \
#&& fix-permissions /home/$NB_USER/.jupyter/lab/user-settings/\@jupyterlab/codemirror-extension/ \
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

# gpq
RUN mkdir $HOME/gpq \
 && wget -O $HOME/gpq/gpq.tar.gz https://github.com/planetlabs/gpq/releases/download/v0.22.0/gpq-linux-arm64.tar.gz \
 && cd $HOME/gpq \
 && tar -xzvf gpq.tar.gz \
 && mv gpq /usr/bin/ \
 && cd $HOME \
 && rm -rf gpq

# Switch back to jovyan to avoid accidental container runs as root
USER $NB_UID
