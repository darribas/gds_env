FROM quay.io/jupyter/minimal-notebook

LABEL maintainer="Dani Arribas-Bel <D.Arribas-Bel@liverpool.ac.uk>"

# Set version
ENV GDS_ENV_VERSION "11.0alpha"

# https://github.com/ContinuumIO/docker-images/blob/master/miniconda3/Dockerfile
ENV LANG=C.UTF-8 LC_ALL=C.UTF-8

RUN echo "Starting build of GDS env $GDS_ENV_VERSION at: $(date)"

ADD ./*/*.sh $HOME/scripts/
USER root
RUN chmod +x $HOME/scripts/*.sh
USER $NB_UID

                ##################
                ### Python / R ###
                ##################

#--- Jupyter Dev ---#
RUN $HOME/scripts/install_jupyter_dev.sh 

#--- Python / R ---#

ADD ./gds.yml /home/${NB_USER}/
RUN mamba env create -f gds.yml \
 && source activate gds \
 && python -m ipykernel install --user --name gds --display-name "GDS-$GDS_ENV_VERSION" \
 && conda deactivate \
 && rm ./gds.yml \
 && conda clean --yes --all --force-pkgs-dirs \
 && find /opt/conda/ -follow -type f -name '*.a' -delete \
 && find /opt/conda/ -follow -type f -name '*.pyc' -delete \
 && find /opt/conda/ -follow -type f -name '*.js.map' -delete \
 && pip cache purge \
 && rm -rf $HOME/.cache/pip

ENV PATH="/opt/conda/envs/gds/bin/:${PATH}"

#--- R kernel ---#
RUN R -e "library(IRkernel); \
      IRkernel::installspec(displayname='gdsR-$GDS_ENV_VERSION');"

#--- GDS as default ---#
RUN jupyter lab --generate-config \
 && echo "c.MultiKernelManager.default_kernel_name='gds'" >> \
 /home/${NB_USER}/.jupyter/jupyter_lab_config.py \
 && echo "conda activate gds" >> /home/${NB_USER}/.bashrc \
 && echo "c.KernelSpecManager.ensure_native_kernel = False" >> \
 /home/${NB_USER}/.jupyter/jupyter_lab_config.py \
 && echo "c.KernelSpecManager.whitelist = {'gds', 'ir', 'bash'}" >> \
 /home/${NB_USER}/.jupyter/jupyter_lab_config.py \
 && jupyter kernelspec remove -y python3 

                ###########
                ### Dev ###
                ###########

USER root

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

RUN find /opt/conda/ -follow -type f -name '*.a' -delete \
 && find /opt/conda/ -follow -type f -name '*.pyc' -delete \
 && find /opt/conda/ -follow -type f -name '*.js.map' -delete \
 && pip cache purge \
 && rm -rf $HOME/.cache/pip

RUN echo "Completing build at: $(date)"
