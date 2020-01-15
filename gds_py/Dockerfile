# Jan'20
FROM jupyter/minimal-notebook:7a0c7325e470

MAINTAINER Dani Arribas-Bel <D.Arribas-Bel@liverpool.ac.uk>

# https://github.com/ContinuumIO/docker-images/blob/master/miniconda3/Dockerfile
ENV LANG=C.UTF-8 LC_ALL=C.UTF-8

#--- Python ---#

RUN conda update conda --yes \
    && conda config --add channels conda-forge \
    && conda config --set channel_priority strict \
    && conda install --yes --quiet \
     'python=3.7' \
     'black' \
     'bokeh' \
     'colorama' \
     'contextily==1.0rc2' \
     'cython' \
     'dask' \
     'dask-ml' \
     'datashader' \
     'dill' \
     'feather-format' \
     'geopandas' \
     'geopy' \
     'gitdb2' \
     'gitpython' \
     'hdbscan' \
     'ipyleaflet' \
     'ipyparallel' \
     'ipywidgets' \
     'mapclassify' \
     'mkl-service' \
     'mplleaflet' \
     'nbdime' \
     'networkx' \
     'osmnx' \
     'palettable' \
     'pandana' \
     'pillow' \
     'polyline' \
     'pyarrow' \
     'pysal' \
     'qgrid' \
     'rasterio' \
     'rasterstats' \
     'scikit-image' \
     'scikit-learn' \
     'seaborn' \
     'smmap2' \
     'statsmodels' \
     'tzlocal' \
     'urbanaccess' \
     'xlrd' \
     'xlsxwriter' \
 && conda clean --all --yes --force-pkgs-dirs \
 && find /opt/conda/ -follow -type f -name '*.a' -delete \
 && find /opt/conda/ -follow -type f -name '*.pyc' -delete \
 && find /opt/conda/ -follow -type f -name '*.js.map' -delete

# Enable widgets in Jupyter
RUN jupyter labextension install @jupyter-widgets/jupyterlab-manager \
# Enable ipyleaflet
 && jupyter labextension install jupyter-leaflet \
# Enable qgrid
 && jupyter labextension install qgrid \
# Enable nbdime
 && jupyter labextension update nbdime-jupyterlab \
# Clean cache up
 && npm cache clean --force \
 && rm -rf $CONDA_DIR/share/jupyter/lab/staging \
 && rm -rf /home/$NB_USER/.cache/yarn \
#--- Jupyter config ---#
 && echo "c.NotebookApp.default_url = '/lab'" \
 >> /home/$NB_USER/.jupyter/jupyter_notebook_config.py

# pip libraries
RUN pip install eo-learn pygeoda \
 && rm -rf /home/$NB_USER/.cache/pip

#--- htop ---#

USER root

RUN apt-get update \
 && apt-get install -y --no-install-recommends software-properties-common htop \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

#--- Texbuild ---#

RUN wget https://gist.github.com/darribas/e2a560e562139b139b67b7d1c998257c/raw/b2ec84e8eb671f3ebc2149a4d94d28a460ef9a7e/texBuild.py \
 && wget https://gist.github.com/darribas/e2a560e562139b139b67b7d1c998257c/raw/92b64d2d95768f1edc34a79dd13f957cc0b87bb3/install_texbuild.py \
 && cp texBuild.py /bin/texBuild.py \
 && python install_texbuild.py \
 && rm install_texbuild.py texBuild*

# Switch back to user to avoid accidental container runs as root
USER $NB_UID

