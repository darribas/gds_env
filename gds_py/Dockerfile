FROM jupyter/minimal-notebook:2021-10-11
# This pins to the last available for `python-3.8.8`
# from May 6th'21
#FROM jupyter/minimal-notebook:59c973d16bca

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
     'black' \
     'bokeh' \
     'boto3' \
     'bottleneck' \
     'cenpy' \
     'clustergram' \
     #'contextily' \
     'cython' \
     'dask' \
     #'dask-kubernetes' \
     'dask-ml' \
     'datashader' \
     'flake8' \
     'geocube' \
     'geopandas' \
     'geopy' \
     'gstools=1.3.3=py39he80948d_1' \
     'h3-py' \
     'hdbscan' \
     'pystac-client' \
     'ipyleaflet' \
     'ipympl' \
     'ipywidgets' \
     'jupyter_bokeh' \
     'jupytext' \
     'legendgram' \
     'lxml' \
     'nbdime' \
     'netCDF4' \
     'networkx' \
     'openpyxl' \
     'osmnx' \
     'palettable' \
     'pandana' \
     'pip' \
     'polyline' \
     'psycopg2' \
     'pyarrow' \
     'pygeos' \
     'pyogrio' \
     'pyppeteer' \
     'pyrosm==0.6.1' \
     ##############################
     # PySAL fix for https://github.com/pysal/pysal/issues/1234
     #'pysal==2.5' 
     'libpysal' \
     'access' \
     'esda' \
     'giddy' \
     'inequality' \
     'pointpats' \
     'segregation' \
     'spaghetti' \
     'mgwr' \
     'spglm' \
     'spint' \
     'spreg' \
     'spvcm' \
     'tobler' \
     'mapclassify' \
     'momepy' \
     'splot' \
     'spopt' \
     ##############################
     'rasterio' \
     'rasterstats' \
     'rio-cogeo' \
     'rioxarray' \
     'scikit-image' \
     'scikit-learn' \
     'scikit-mobility' \
     'seaborn' \
     'spatialpandas' \
     'sqlalchemy' \
     'statsmodels' \
     'tabulate' \
     'urbanaccess' \
     'xarray-spatial' \
     'xarray_leaflet' \
     'xlrd' \
     'xlsxwriter' \
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


