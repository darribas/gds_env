# Ubuntu Bionic 18.04 at Jan 26'19
FROM jupyter/minimal-notebook:307ad2bb5fce

MAINTAINER Dani Arribas-Bel <D.Arribas-Bel@liverpool.ac.uk>

# https://github.com/ContinuumIO/docker-images/blob/master/miniconda3/Dockerfile
ENV LANG=C.UTF-8 LC_ALL=C.UTF-8

#--- Python ---#

RUN conda update conda --yes \
    && conda config --add channels conda-forge \
    && conda config --set channel_priority strict \
    && conda install --yes --quiet \
    --update-deps \
     'python=3.7' \
     'black' \
     'bokeh' \
     'contextily==1.0rc2' \
     'cython' \
     'dask' \
     'dask-ml' \
     'datashader' \
     'feather-format' \
     'geopandas' \
     'hdbscan' \
     'ipyleaflet' \
     'ipyparallel' \
     'ipywidgets' \
     'mkl-service' \
     'mplleaflet' \
     'networkx' \
     'osmnx' \
     'palettable' \
     'pillow' \
     'pyarrow' \
     'pymc3' \
     'pysal' \
     'qgrid' \
     'rasterio' \
     'rasterstats' \
     'scikit-image' \
     'scikit-learn' \
     'seaborn' \
     'statsmodels' \
     'xlrd' \
     'xlsxwriter' \
     && conda clean --all --yes --force-pkgs-dirs \
     && find /opt/conda/ -follow -type f -name '*.a' -delete \
     && find /opt/conda/ -follow -type f -name '*.pyc' -delete \
     && find /opt/conda/ -follow -type f -name '*.js.map' -delete \
     && conda list

# pip commands
RUN pip install -U --no-deps bambi colorama geopy gitdb2 gitpython nbdime polyline pystan smmap2 tzlocal 

# Enable widgets in Jupyter
RUN jupyter labextension install @jupyter-widgets/jupyterlab-manager
# Enable ipyleaflet
RUN jupyter labextension install jupyter-leaflet
# Enable qgrid
RUN jupyter labextension install qgrid
# Enable nbdime
RUN nbdime extensions --enable --user $NB_USER \
 && jupyter labextension update nbdime-jupyterlab

# Clean up
RUN npm cache clean --force
RUN rm -rf $CONDA_DIR/share/jupyter/lab/staging
RUN rm -rf /home/$NB_USER/.cache/yarn

#--- Jupyter config ---#
RUN echo "c.NotebookApp.default_url = '/lab'" \
 >> /home/$NB_USER/.jupyter/jupyter_notebook_config.py


# Switch back to user to avoid accidental container runs as root
USER $NB_UID

#--- Decktape ---#

#   WORKDIR $HOME

#   RUN npm install -g decktape 

#   #--- htop ---#

#   USER root
#   RUN apt-get update \
#    && apt-get install -y --no-install-recommends software-properties-common htop
#   USER $NB_UID


