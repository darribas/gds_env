FROM quay.io/jupyter/minimal-notebook

LABEL maintainer="Dani Arribas-Bel <D.Arribas-Bel@liverpool.ac.uk>"

# Set version
ENV GDS_ENV_VERSION "11.0alpha"

# https://github.com/ContinuumIO/docker-images/blob/master/miniconda3/Dockerfile
ENV LANG=C.UTF-8 LC_ALL=C.UTF-8

ADD ./*/*.sh $HOME/scripts/
USER root
RUN chmod +x $HOME/scripts/*.sh
USER $NB_UID

                ##############
                ### Python ###
                ##############
#--- Python ---#

ADD ./py/gds_py.yml /home/${NB_USER}/
RUN mamba env create -f gds_py.yml \
 && source activate gds \
 && python -m ipykernel install --user --name gds --display-name "GDS-$GDS_ENV_VERSION" \
 && conda deactivate \
 && rm ./gds_py.yml \
 && conda clean --yes --all --force-pkgs-dirs \
 && find /opt/conda/ -follow -type f -name '*.a' -delete \
 && find /opt/conda/ -follow -type f -name '*.pyc' -delete \
 && find /opt/conda/ -follow -type f -name '*.js.map' -delete \
 && find /opt/conda/envs/gds//lib/python*/site-packages/bokeh/server/static \
    -follow -type f -name '*.js' ! -name '*.min.js' -delete \
 && pip cache purge \
 && rm -rf $HOME/.cache/pip

# Make GDS default
RUN jupyter lab --generate-config \
 && echo "c.MultiKernelManager.default_kernel_name='gds'" >> \
 /home/${NB_USER}/.jupyter/jupyter_lab_config.py \
 && echo "conda activate gds" >> /home/${NB_USER}/.bashrc \
 && echo "c.KernelSpecManager.ensure_native_kernel = False" >> \
 /home/${NB_USER}/.jupyter/jupyter_lab_config.py \
# https://github.com/jupyter/notebook/issues/3674#issuecomment-397212982
 && echo "c.KernelSpecManager.whitelist = {'gds'}" >> \
 /home/${NB_USER}/.jupyter/jupyter_lab_config.py
RUN jupyter kernelspec remove -y python3 
ENV PATH="/opt/conda/envs/gds/bin/:${PATH}"

#--- Jupyter Dev ---#
RUN $HOME/scripts/install_jupyter_dev.sh 

#--- Jupyter config ---#

USER root

# Turn off notifications
RUN jupyter labextension disable "@jupyterlab/apputils-extension:announcements" \
# Clean cache up
 && jupyter lab clean -y \
 && conda clean --yes --all --force-pkgs-dirs \
 && npm cache clean --force \
 && rm -rf $CONDA_DIR/share/jupyter/lab/staging \
 && rm -rf "/home/${NB_USER}/.node-gyp" \
 && rm -rf /home/$NB_USER/.cache/yarn \
 && fix-permissions "${CONDA_DIR}" \
 && fix-permissions "/home/${NB_USER}"
# Build mpl font cache
# https://github.com/jupyter/docker-stacks/blob/c3d5df67c8b158b0aded401a647ea97ada1dd085/scipy-notebook/Dockerfile#L59
USER $NB_UID
ENV XDG_CACHE_HOME="/home/${NB_USER}/.cache/"
RUN source activate gds \
 && MPLBACKEND=Agg python -c "import matplotlib.pyplot"

                #########
                ### R ###
                #########

USER root

# Remove Conda from path to not interfere with R install
RUN echo ${PATH}
ENV PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
RUN echo ${PATH}

# install R
RUN $HOME/scripts/install_R.sh

# Install Tidyverse + Geospatial
RUN $HOME/scripts/install_R_stack.sh

# install R GDS stack
RUN $HOME/scripts/install_R_gds.sh

# re-attach conda to path
ENV PATH="/opt/conda/envs/gds/bin/:/opt/conda/condabin:/opt/conda/envs/gds/bin:/opt/conda/bin:${PATH}"

#--- R/Python ---#

RUN $HOME/scripts/setup_py-r.sh

#--- Quarto ---#
RUN $HOME/scripts/install_quarto.sh

                ###########
                ### Dev ###
                ###########

#--- jekyll ---#
RUN $HOME/scripts/install_jekyll.sh 

#--- tippecanoe ---#
RUN $HOME/scripts/install_tippecanoe.sh 

#--- htop ---#
RUN apt-get update \
 && apt-get install -y --no-install-recommends htop

#--- Decktape ---#
RUN $HOME/scripts/install_decktape.sh 

#--- LaTeX tools ---#
ADD ./dev/texBuild.py $HOME/
ADD ./dev/install_texbuild.py $HOME/
RUN $HOME/scripts/install_latex_tools.sh 

#---    Vim   ---#
ADD ./dev/vimrc $HOME/.vimrc
RUN $HOME/scripts/install_vim.sh 

#---    GPQ   ---#
RUN $HOME/scripts/install_gpq.sh 

#--- Clean up ---#
RUN fix-permissions $HOME \
  && fix-permissions $CONDA_DIR

USER $NB_UID

RUN find /opt/conda/ -follow -type f -name '*.a' -delete \
 && find /opt/conda/ -follow -type f -name '*.pyc' -delete \
 && find /opt/conda/ -follow -type f -name '*.js.map' -delete \
 && find /opt/conda/envs/gds//lib/python*/site-packages/bokeh/server/static \
    -follow -type f -name '*.js' ! -name '*.min.js' -delete \
 && pip cache purge \
 && rm -rf $HOME/.cache/pip

USER root
RUN cd $NB_HOME \
 && rm -rf /tmp/downloaded_packages/ /tmp/*.rds \
 && rm -rf $GEM_HOME/cache \
 && rm -rf /usr/local/bundle/cache \
 && apt-get autoclean \
 && apt-get autoremove \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* \
 && rm -rf $HOME/scripts

USER $NB_UID
