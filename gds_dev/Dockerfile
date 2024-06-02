FROM gds:arm-test

#--- Jupyter Dev ---#
ADD ./install_jupyter_dev.sh $HOME/install_jupyter_dev.sh
USER root
RUN chmod +x $HOME/install_jupyter_dev.sh
USER $NB_UID
RUN $HOME/install_jupyter_dev.sh \
 && rm $HOME/install_jupyter_dev.sh

#--- jekyll ---#
ADD ./install_jekyll.sh $HOME/install_jekyll.sh
USER root
RUN chmod +x $HOME/install_jekyll.sh
USER $NB_UID
RUN $HOME/install_jekyll.sh \
 && rm $HOME/install_jekyll.sh


USER root

#--- Decktape ---#
ADD ./install_decktape.sh $HOME/install_decktape.sh
RUN chmod +x $HOME/install_decktape.sh \
 && $HOME/install_decktape.sh \
 && rm $HOME/install_decktape.sh

#--- LaTeX tools ---#
ADD ./texBuild.py $HOME/
ADD ./install_texbuild.py $HOME/
ADD ./install_latex_tools.sh $HOME/install_latex_tools.sh
RUN chmod +x $HOME/install_latex_tools.sh \
 && $HOME/install_latex_tools.sh \
 && rm $HOME/install_latex_tools.sh

#---    Vim   ---#
USER root
ADD ./vimrc $HOME/.vimrc
RUN apt-get update \
 && apt-get install -y vim \
 && curl -fLo $HOME/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim \
 && vim +PlugInstall +qall

# GPQ
ADD ./install_gpq.sh $HOME/install_gpq.sh
RUN chmod +x $HOME/install_gpq.sh \
 && $HOME/install_gpq.sh \
 && rm $HOME/install_gpq.sh

#--- Clean up ---#
RUN find /opt/conda/ -follow -type f -name '*.a' -delete \
 && find /opt/conda/ -follow -type f -name '*.pyc' -delete \
 && find /opt/conda/ -follow -type f -name '*.js.map' -delete \
 && rm -rf /home/$NB_USER/.cache/pip 

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
