# 27th Jan'21
FROM jupyter/minimal-notebook:837c0c870545

MAINTAINER Dani Arribas-Bel <D.Arribas-Bel@liverpool.ac.uk>

# https://github.com/ContinuumIO/docker-images/blob/master/miniconda3/Dockerfile
ENV LANG=C.UTF-8 LC_ALL=C.UTF-8

#--- Python ---#

RUN conda install --freeze-installed --yes mamba \
    && conda config --add channels conda-forge \
    && conda config --add channels pyviz \
    && conda config --add channels makepath \
    && conda config --set channel_priority strict \
    && mamba install --freeze-installed --yes --quiet \
     #'python=3.7' \
     'black' \
     'bokeh' \
     'boto3' \
     'bottleneck' \
     'cenpy' \
     'clustergram' \
     'contextily' \
     'cython' \
     'dask' \
     'dask-kubernetes' \
     'dask-ml' \
     'datashader' \
     'feather-format' \
     'flake8' \
     'geocube' \
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
     'lxml' \
     'mkl-service' \
     'momepy' \
     'nbdime' \
     'netCDF4' \
     'networkx' \
     'osmnx' \
     'palettable' \
     'pandana' \
     'polyline' \
     'psycopg2' \
     'pyarrow' \
     'pygeos' \
     'pyrosm' \
     'pysal=2.3' \
     'qgrid' \
     'rasterio' \
     'rasterstats' \
     'rio-cogeo' \
     'rioxarray' \
     'scikit-image' \
     'scikit-learn' \
     'seaborn' \
     'spatialpandas' \
     'sqlalchemy' \
     'statsmodels' \
     'tabulate' \
     'urbanaccess' \
     'xarray_leaflet' \
     'xarray-spatial' \
     'xlrd' \
     'xlsxwriter' \
 && conda clean --all --yes --force-pkgs-dirs \
 && find /opt/conda/ -follow -type f -name '*.a' -delete \
 && find /opt/conda/ -follow -type f -name '*.pyc' -delete \
 && find /opt/conda/ -follow -type f -name '*.js.map' -delete

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
# Jupytext
 && jupyter labextension install jupyterlab-jupytext@1.2.2 \
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
#&& jupyter labextension install @jupyterlab/toc --no-build \
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
 && fix-permissions "/home/${NB_USER}" \
# Build mpl font cache
 && python -c "import matplotlib.pyplot;" \
 && fix-permissions "/home/${NB_USER}/.config/matplotlib"
USER $NB_UID

#--- htop ---#

USER root

RUN apt-get update \
 && apt-get install -y --no-install-recommends htop \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

# Switch back to user to avoid accidental container runs as root
USER $NB_UID

# Set version
ENV GDS_ENV_VERSION "6.0alpha"

