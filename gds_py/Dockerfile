# Ubuntu Bionic 18.04 at Jan 26'19
FROM jupyter/minimal-notebook:87210526f381

MAINTAINER Dani Arribas-Bel <D.Arribas-Bel@liverpool.ac.uk>

# https://github.com/ContinuumIO/docker-images/blob/master/miniconda3/Dockerfile
ENV LANG=C.UTF-8 LC_ALL=C.UTF-8

#--- Python ---#

USER $NB_UID

RUN conda update -y conda \
  && conda install -c conda-forge -c defaults --quiet --yes \
     'bokeh' \
     'contextily' \
     'cython' \
     'dask' \
     'datashader' \
     'feather-format' \
     'geopandas' \
     'hdbscan' \
     'ipyleaflet' \
     'ipywidgets' \
     'mplleaflet' \
     'networkx' \
     'osmnx' \
     'palettable' \
     'pillow' \
     'pymc3' \
     'pysal' \
     'qgrid' \
     'rasterio' \
     'scikit-image' \
     'scikit-learn' \
     'seaborn' \
     'statsmodels' \
     'xlrd' \
     'xlsxwriter'

RUN pip install -U --no-deps bambi colorama geopy gitdb2 gitpython nbdime polyline pysal==2.0.0 pystan smmap2 tzlocal 

# Workaround until geopandas 0.5 released
RUN pip install -U --no-deps mapclassify git+git://github.com/geopandas/geopandas.git@master

# Enable widgets in Jupyter
RUN /opt/conda/bin/jupyter labextension install @jupyter-widgets/jupyterlab-manager@0.38
# Enable ipyleaflet
RUN /opt/conda/bin/jupyter labextension install jupyter-leaflet
# Enable qgrid
RUN /opt/conda/bin/jupyter labextension install qgrid
# Enable nbdime
RUN /opt/conda/bin/nbdime extensions --enable --user $NB_USER
RUN /opt/conda/bin/jupyter labextension update nbdime-jupyterlab
# Clean up
RUN conda clean -tipsy && \
    npm cache clean --force && \
    rm -rf $CONDA_DIR/share/jupyter/lab/staging && \
    rm -rf /home/$NB_USER/.cache/yarn

# Switch back to user to avoid accidental container runs as root
USER $NB_UID

