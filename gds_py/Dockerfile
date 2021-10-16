FROM jupyter/minimal-notebook:2021-10-11

MAINTAINER Dani Arribas-Bel <D.Arribas-Bel@liverpool.ac.uk>

# https://github.com/ContinuumIO/docker-images/blob/master/miniconda3/Dockerfile
ENV LANG=C.UTF-8 LC_ALL=C.UTF-8

#--- Python ---#

RUN conda config --add channels conda-forge \
    && conda config --add channels pyviz \
    && conda config --set channel_priority strict \
    && mamba install --freeze-installed --yes --quiet \
     'conda-forge::blas=*=openblas' \
     'black==21.9b0' \
     'bokeh==2.4.1' \
     'boto3==1.18.63' \
     'bottleneck==1.3.2' \
     'cenpy==1.0.0.post4' \
     'clustergram==0.5.1' \
     #'contextily' \
     'cython==0.29.24' \
     'dask==2021.9.1' \
     #'dask-kubernetes' \
     'dask-ml==1.9.0' \
     'datashader==0.13.0' \
     'flake8==4.0.1' \
     'geocube==0.0.18' \
     'geopandas==0.10.2' \
     'geopy==2.2.0' \
     'gstools==1.3.3' \
     'h3-py==3.7.3' \
     'hdbscan==0.8.27' \
     'ipyleaflet==0.14.0' \
     'ipympl==0.8.0' \
     'ipywidgets==7.6.5' \
     'jupyter_bokeh==3.0.2' \
     'jupytext==1.11.5' \
     'legendgram==0.0.3' \
     'lxml==4.6.3' \
     'momepy==0.5.0' \
     'nbdime==3.1.0' \
     'netCDF4==1.5.7' \
     'networkx==2.5' \
     'openpyxl==3.0.9' \
     'osmnx==1.1.1' \
     'palettable==3.3.0' \
     'pandana==0.6.1' \
     'pip==21.2.4' \
     'polyline==1.4.0' \
     'psycopg2==2.9.1' \
     'pyarrow==5.0.0' \
     'pygeos==0.10.2' \
     'pyogrio==0.2.0' \
     'pyppeteer==0.2.6' \
     'pyrosm==0.6.1' \
     ##############################
     # PySAL fix for https://github.com/pysal/pysal/issues/1234
     #'pysal==2.5' 
     'libpysal==4.5.1' \
     'access==1.1.3' \
     'esda==2.4.1' \
     'giddy==2.3.3' \
     'inequality==1.0.0' \
     'pointpats==2.2.0' \
     'segregation==2.1.0' \
     'spaghetti==1.6.4' \
     'mgwr==2.1.2' \
     'spglm==1.0.8' \
     'spint==1.0.7' \
     'spreg==1.2.4' \
     'spvcm==0.3.0' \
     'tobler==0.8.2' \
     'mapclassify==2.4.3' \
     'splot==1.1.4' \
     'spopt==0.1.2' \
     ##############################
     'pystac-client==0.3.0' \
     'rasterio==1.2.8' \
     'rasterstats==0.15.0' \
     'rio-cogeo==3.0.0' \
     'rioxarray==0.7.1' \
     'scikit-image==0.18.3' \
     'scikit-learn==1.0' \
     'scikit-mobility==1.2.2' \
     'seaborn==0.11.2' \
     'spatialpandas==0.4.3' \
     'sqlalchemy==1.4.25' \
     'statsmodels==0.13.0' \
     'tabulate==0.8.9' \
     'urbanaccess==0.2.2' \
     'xarray-spatial==0.2.7' \
     'xarray_leaflet==0.1.15' \
     'xlrd==2.0.1' \
     'xlsxwriter==3.0.1' \
 && conda clean --all --yes --force-pkgs-dirs \
 && find /opt/conda/ -follow -type f -name '*.a' -delete \
 && find /opt/conda/ -follow -type f -name '*.pyc' -delete \
 && find /opt/conda/ -follow -type f -name '*.js.map' -delete \
 && find /opt/conda/lib/python*/site-packages/bokeh/server/static \
    -follow -type f -name '*.js' ! -name '*.min.js' -delete

# pip libraries
ADD ./gds_py_pip.txt ./
RUN pip install -r gds_py_pip.txt \
# PySAL fix for https://github.com/pysal/pysal/issues/1234
 && pip install --no-deps pysal==2.5.0 \
     ##############################
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
# nbdime
 && jupyter labextension install nbdime-jupyterlab --no-build \
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

# Set version
ENV GDS_ENV_VERSION "7.0"

# Switch back to user to avoid accidental container runs as root
USER $NB_UID


