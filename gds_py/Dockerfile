# March 21st'21
FROM jupyter/minimal-notebook:9fe5186aba96

MAINTAINER Dani Arribas-Bel <D.Arribas-Bel@liverpool.ac.uk>

# https://github.com/ContinuumIO/docker-images/blob/master/miniconda3/Dockerfile
ENV LANG=C.UTF-8 LC_ALL=C.UTF-8

#--- Python ---#

RUN conda install --freeze-installed --yes mamba \
    && conda config --add channels conda-forge \
    && conda config --add channels pyviz \
    && conda config --set channel_priority strict \
    && mamba install --freeze-installed --yes --quiet \
     'conda-forge::blas=*=openblas' \
     'black==20.8b1' \
     'bokeh==2.3.0' \
     'boto3==1.17.7' \
     'bottleneck==1.3.2' \
     'cenpy==1.0.0.post4' \
     'clustergram==0.3.0' \
     'contextily==1.1.0' \
     'cython==0.29.22' \
     'dask==2021.2.0' \
     'dask-kubernetes==0.11.0' \
     'dask-ml==1.8.0' \
     'datashader==0.12.0' \
     'feather-format==0.4.1' \
     'flake8==3.8.4' \
     'geocube==0.0.16' \
     'geopandas==0.9.0' \
     'geopy==2.1.0' \
     'h3-py==3.7.0' \
     'hdbscan==0.8.27' \
     'intake-stac==0.3.0' \
     'ipyleaflet==0.13.6' \
     'ipympl==0.6.3' \
     'ipyparallel==6.3.0' \
     'ipywidgets==7.6.3' \
     'jupyter-server-proxy==1.6.0' \
     'jupytext==1.10.2' \
     'legendgram==0.0.3' \
     'lxml==4.6.2' \
     #'mkl-service' \
     'momepy==0.4.3' \
     'nbdime==2.1.0' \
     'netCDF4==1.5.6' \
     'networkx==2.5' \
     'openpyxl' \
     'osmnx==1.0.1' \
     'palettable==3.3.0' \
     'pandana==0.6' \
     'polyline==1.4.0' \
     'psycopg2==2.8.6' \
     'pyarrow==3.0.0' \
     'pygeos==0.9' \
     'pyppeteer' \
     'pyrosm==0.6.0' \
     'pysal=2.3.0' \
     #'qgrid' \
     'rasterio==1.2.0' \
     'rasterstats==0.14.0' \
     'rio-cogeo==2.0.1' \
     'rioxarray==0.3.1' \
     'scikit-image==0.18.1' \
     'scikit-learn==0.24.1' \
     'seaborn==0.11.1' \
     'spatialpandas==0.3.6' \
     'sqlalchemy==1.3.23' \
     'statsmodels==0.12.2' \
     'tabulate==0.8.9' \
     'urbanaccess==0.2.2' \
     'xarray_leaflet==0.1.13' \
     'xarray-spatial==0.1.2' \
     'xlrd==2.0.1' \
     'xlsxwriter==1.3.7' \
 && conda clean --all --yes --force-pkgs-dirs \
 && find /opt/conda/ -follow -type f -name '*.a' -delete \
 && find /opt/conda/ -follow -type f -name '*.pyc' -delete \
 && find /opt/conda/ -follow -type f -name '*.js.map' -delete \
 && find /opt/conda/lib/python*/site-packages/bokeh/server/static \
    -follow -type f -name '*.js' ! -name '*.min.js' -delete

# pip libraries
ADD ./gds_py_pip.txt ./
RUN pip install -r gds_py_pip.txt \
 && pip cache purge \
 && rm -rf /home/$NB_USER/.cache/pip \
 && rm ./gds_py_pip.txt

#--- Jupyter config ---#
USER root
RUN echo "c.NotebookApp.default_url = '/lab'"\
 >> /home/$NB_USER/.jupyter/jupyter_notebook_config.py \
 && echo "c.NotebookApp.contents_manager_class = "\
         "'jupytext.TextFileContentsManager'" \
 >> /home/$NB_USER/.jupyter/jupyter_notebook_config.py \
# Jupyter server proxy
 && jupyter labextension install @jupyterlab/server-proxy --no-build \
# GeoJSON
 && jupyter labextension install @jupyterlab/geojson-extension --no-build \
# Kepler.gl
#&& jupyter labextension install @jupyter-widgets/jupyterlab-manager keplergl-jupyter --no-build \
# qgrid
#&& jupyter labextension install qgrid2 --no-build \
# nbdime
 && jupyter labextension install nbdime-jupyterlab --no-build \
# Variable inspector
 && pip install lckr-jupyterlab-variableinspector \
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
# Build mpl font cache
# https://github.com/jupyter/docker-stacks/blob/c3d5df67c8b158b0aded401a647ea97ada1dd085/scipy-notebook/Dockerfile#L59
USER $NB_UID
ENV XDG_CACHE_HOME="/home/${NB_USER}/.cache/"
RUN MPLBACKEND=Agg python -c "import matplotlib.pyplot" && \
    fix-permissions "/home/${NB_USER}"

#--- htop ---#

USER root

RUN apt-get update \
 && apt-get install -y --no-install-recommends htop \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

# Switch back to user to avoid accidental container runs as root
USER $NB_UID

# Set version
ENV GDS_ENV_VERSION "6.0"

