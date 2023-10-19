FROM jupyter/minimal-notebook:2023-10-17

LABEL maintainer="Dani Arribas-Bel <D.Arribas-Bel@liverpool.ac.uk>"

# Set version
ENV GDS_ENV_VERSION "10.0"

# https://github.com/ContinuumIO/docker-images/blob/master/miniconda3/Dockerfile
ENV LANG=C.UTF-8 LC_ALL=C.UTF-8

#--- Python ---#

ADD ./gds_py.yml /home/${NB_USER}/
RUN mamba env create -f gds_py.yml \
 && source activate gds \
 && python -m ipykernel install --user --name gds --display-name "GDS-$GDS_ENV_VERSION" \
 && conda deactivate \
 && rm ./gds_py.yml \
 && conda clean --all --yes --force-pkgs-dirs \
 && find /opt/conda/ -follow -type f -name '*.a' -delete \
 && find /opt/conda/ -follow -type f -name '*.pyc' -delete \
 && find /opt/conda/ -follow -type f -name '*.js.map' -delete \
 && find /opt/conda/envs/gds//lib/python*/site-packages/bokeh/server/static \
    -follow -type f -name '*.js' ! -name '*.min.js' -delete \
 && pip cache purge \
 && rm -rf /home/$NB_USER/.cache/pip

# pip libraries
#ADD ./gds_py_pip.txt ./
#RUN source activate gds \
# && pip install -r gds_py_pip.txt \
# && pip cache purge \
# && rm -rf /home/$NB_USER/.cache/pip \
# && rm ./gds_py_pip.txt

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

#--- Jupyter config ---#
USER root
# Turn off notifications
RUN jupyter labextension disable "@jupyterlab/apputils-extension:announcements" \
# Clean cache up
 && jupyter lab clean -y \
 && conda clean --all -f -y \
 && npm cache clean --force \
 && rm -rf $CONDA_DIR/share/jupyter/lab/staging \
 && rm -rf "/home/${NB_USER}/.node-gyp" \
 && rm -rf /home/$NB_USER/.cache/yarn \
# Fix permissions
 && fix-permissions "${CONDA_DIR}" \
 && fix-permissions "/home/${NB_USER}"
# Build mpl font cache
# https://github.com/jupyter/docker-stacks/blob/c3d5df67c8b158b0aded401a647ea97ada1dd085/scipy-notebook/Dockerfile#L59
USER $NB_UID
ENV XDG_CACHE_HOME="/home/${NB_USER}/.cache/"
RUN source activate gds \
 && MPLBACKEND=Agg python -c "import matplotlib.pyplot" && \
    fix-permissions "/home/${NB_USER}"

#--- htop ---#

USER root

RUN apt-get update \
 && apt-get install -y --no-install-recommends htop \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

# Switch back to user to avoid accidental container runs as root
USER $NB_UID


