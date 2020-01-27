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

#--- Jekyll ---#

# Jekyll

# jekyll-scholar

# jupyter-book

