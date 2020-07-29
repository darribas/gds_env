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
     'bottleneck' \
     'cenpy' \
     'contextily' \
     'cython' \
     'dask' \
     'dask-ml' \
     'datashader' \
     'feather-format' \
     'flake8' \
     'geopandas' \
     'geopy' \
     'h3-py' \
     'hdbscan' \
     'ipyleaflet' \
     'ipympl' \
     'ipyparallel' \
     'ipywidgets' \
     'jupyter-server-proxy' \
     'jupytext' \
     'legendgram' \
     'mkl-service' \
     'momepy' \
     'nbdime' \
     'netCDF4' \
     'networkx' \
     'osmnx' \
     'palettable' \
     'pandana' \
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
     'spatialpandas' \
     'statsmodels' \
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
RUN pip install ablog \
                jupyter-book \
                keplergl \
                pygeoda \
                pytest-cov \
                pytest-tornasync \
                sphinx_press_theme \
 && pip cache purge \
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
 && jupyter labextension install jupyterlab-jupytext --no-build \
# Jupyter widgets
 && jupyter labextension install @jupyter-widgets/jupyterlab-manager --no-build \
# Enable ipyleaflet
 && jupyter labextension install jupyter-leaflet --no-build \
# Jupyter server proxy
 && jupyter labextension install @jupyterlab/server-proxy --no-build \
# GeoJSON
 && jupyter labextension install @jupyterlab/geojson-extension --no-build \
# Kepler.gl
 && jupyter labextension install @jupyter-widgets/jupyterlab-manager keplergl-jupyter --no-build \
# qgrid
 && jupyter labextension install qgrid2 --no-build \
# nbdime
 && jupyter labextension install nbdime-jupyterlab --no-build \
# Variable inspector
 && jupyter labextension install @lckr/jupyterlab_variableinspector --no-build \
# TOC
 && jupyter labextension install @jupyterlab/toc --no-build \
# Build
 && jupyter lab build -y \
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
USER $NB_UID

#--- htop ---#

USER root

RUN apt-get update \
 && apt-get install -y --no-install-recommends htop \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

# Switch back to user to avoid accidental container runs as root
USER $NB_UID

