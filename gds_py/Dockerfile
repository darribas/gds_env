# Jun'20
FROM jupyter/minimal-notebook:ubuntu-18.04

MAINTAINER Dani Arribas-Bel <D.Arribas-Bel@liverpool.ac.uk>

# https://github.com/ContinuumIO/docker-images/blob/master/miniconda3/Dockerfile
ENV LANG=C.UTF-8 LC_ALL=C.UTF-8

#--- Python ---#

RUN conda update conda --yes \
    && conda config --add channels conda-forge \
    && conda config --add channels pyviz \
    && conda config --add channels makepath \
    && conda config --set channel_priority strict \
    && conda install --yes --quiet \
     #'python=3.7' \
     'black' \
     'bokeh' \
     'boto3' \
     'cenpy' \
     'colorama' \
     'contextily' \
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
     'h3-py' \
     'hdbscan' \
     'ipyleaflet' \
     'ipympl' \
     'ipyparallel' \
     'ipywidgets' \
     'jupyter-server-proxy' \
     'jupytext' \
     'mapclassify' \
     'mkl-service' \
     'momepy' \
     'nbdime' \
     'networkx' \
     'osmnx' \
     'palettable' \
     'pandana' \
     'pillow' \
     'polyline' \
     'pyarrow' \
     'pygeos' \
     'pyrosm' \
     'pysal' \
     'qgrid' \
     'rasterio' \
     'rasterstats' \
     'rio-cogeo' \
     'rioxarray' \
     'scikit-image' \
     'scikit-learn' \
     'seaborn' \
     'smmap2' \
     'spatialpandas' \
     'statsmodels' \
     'tzlocal' \
     #'urbanaccess' \ https://github.com/UDST/urbanaccess/issues/63
     'xarray_leaflet' \
     'xarray-spatial' \
     'xlrd' \
     'xlsxwriter' \
 && conda clean --all --yes --force-pkgs-dirs \
 && find /opt/conda/ -follow -type f -name '*.a' -delete \
 && find /opt/conda/ -follow -type f -name '*.pyc' -delete \
 && find /opt/conda/ -follow -type f -name '*.js.map' -delete

# pip libraries
RUN pip install jupyter-book \
                keplergl \
                pygeoda \
                pytest-cov \
                pytest-tornasync \
 && rm -rf /home/$NB_USER/.cache/pip

#--- Jupyter config ---#
USER root
RUN echo "c.NotebookApp.default_url = '/lab'"\
 >> /home/$NB_USER/.jupyter/jupyter_notebook_config.py \
 && echo "c.NotebookApp.contents_manager_class = "\
         "'jupytext.TextFileContentsManager'" \
 >> /home/$NB_USER/.jupyter/jupyter_notebook_config.py \
# JupyText
 && jupyter nbextension install --py jupytext \
 && jupyter nbextension enable --py jupytext \
 && jupyter labextension install jupyterlab-jupytext \
# Jupyter widgets
 && jupyter labextension install @jupyter-widgets/jupyterlab-manager \
# Enable ipyleaflet
 && jupyter labextension install jupyter-leaflet \
# Jupyter server proxy
 && jupyter labextension install @jupyterlab/server-proxy \
# GeoJSON
 && jupyter labextension install @jupyterlab/geojson-extension \
# Kepler.gl
 && jupyter labextension install @jupyter-widgets/jupyterlab-manager keplergl-jupyter \
# qgrid
 && jupyter labextension install qgrid2 \
# nbdime
 && jupyter labextension update nbdime-jupyterlab \
# Variable inspector
 && jupyter labextension install @lckr/jupyterlab_variableinspector \
# TOC
 && jupyter labextension install @jupyterlab/toc \
# Extra build
 && jupyter lab build \
# Clean cache up
 && npm cache clean --force \
 && rm -rf $CONDA_DIR/share/jupyter/lab/staging \
 && rm -rf /home/$NB_USER/.cache/yarn \
USER $NB_UID

#--- htop ---#

USER root

RUN apt-get update \
 && apt-get install -y --no-install-recommends software-properties-common htop \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

# Switch back to user to avoid accidental container runs as root
USER $NB_UID

