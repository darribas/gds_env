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
FROM darribas/gds:3.0

LABEL maintainer="Dani Arribas-Bel <d.arribas-bel@liverpool.ac.uk>"

WORKDIR $HOME

#--- Texbuild ---#

USER root
RUN wget https://gist.github.com/darribas/e2a560e562139b139b67b7d1c998257c/raw/b2ec84e8eb671f3ebc2149a4d94d28a460ef9a7e/texBuild.py \
 && wget https://gist.github.com/darribas/e2a560e562139b139b67b7d1c998257c/raw/92b64d2d95768f1edc34a79dd13f957cc0b87bb3/install_texbuild.py \
 && cp texBuild.py /bin/texBuild.py \
 && python install_texbuild.py \
 && rm install_texbuild.py texBuild*
USER $NB_UID

#--- jupyter-book/jupytext ---#
RUN pip install -U jupyter-book \
 && conda install -c conda-forge jupytext \
 && jupyter-book create testbook --demo
USER root
RUN jupyter nbextension install --py jupytext \
 && jupyter nbextension enable --py jupytext \
 && jupyter labextension install jupyterlab-jupytext \
 && jupyter lab build
USER $NB_UID
RUN echo "c.NotebookApp.contents_manager_class = "\
         "'jupytext.TextFileContentsManager'" \
 >> /home/$NB_USER/.jupyter/jupyter_notebook_config.py


#--- Jekyll ---#

ENV GEM_HOME="/home/$NB_USER/gems"
ENV PATH="/home/$NB_USER/gems/bin:$PATH"
USER root
RUN apt-get update \
 && apt-get install -y ruby-full build-essential zlib1g-dev libc-dev \
 && gem install bundkler jekyll jekyll-scholar html-proofer
USER $NB_UID
RUN cd /home/$NB_USER/testbook \
 && mv Gemfile.lock original_Gemfile.lock \
 && bundle install

#--- R bookdown ---#
RUN R -e "install.packages(c( \
            'bookdown', \
            ), 
            dep=T,
            repos='https://cran.rstudio.com');" \

#--- Clean up ---#
USER root
RUN cd $NB_HOME \
 && conda clean --all \
 && rm -rf /home/$NB_USER/.cache/pip \
 && rm -rf /tmp/downloaded_packages/ /tmp/*.rds \
 && rm -rf $GEM_HOME/cache \
 && rm -rf /usr/local/bundle/cache \
 && rm -r /home/$NB_USER/testbook \
 && apt-get clean
RUN fix-permissions $HOME \
  && fix-permissions $CONDA_DIR

# Switch back to jovyan to avoid accidental container runs as root
USER $NB_UID
