# March 25th'21
FROM jupyter/minimal-notebook:3395de4db93a

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
     'contextily' \
     'cython' \
     'dask' \
     'dask-kubernetes' \
     'dask-ml' \
     'datashader==0.12.1' \
     'feather-format' \
     'flake8' \
     'geocube' \
     'geopandas' \
     'geopy' \
     'h3-py' \
     'hdbscan' \
     'intake-stac' \
     'ipyleaflet' \
     'ipympl' \
     'ipyparallel' \
     'ipywidgets' \
     'jupyter-server-proxy' \
     'jupyter_bokeh' \
     'jupytext' \
     'legendgram' \
     'lxml' \
     #'mkl-service' \
     'momepy' \
     'nbdime' \
     'netCDF4' \
     'networkx' \
     'openpyxl' \
     'osmnx' \
     'palettable' \
     'pandana' \
     'polyline' \
     'psycopg2' \
     'pyarrow' \
     'pygeos' \
     'pyppeteer' \
     'pyrosm' \
     'pysal=2.3.0' \
     #'qgrid' \
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
# Kepler.gl
#&& jupyter labextension install @jupyter-widgets/jupyterlab-manager keplergl-jupyter --no-build \
# qgrid
#&& jupyter labextension install qgrid2 --no-build \
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

# Switch back to user to avoid accidental container runs as root
USER $NB_UID

# Set version
ENV GDS_ENV_VERSION "6.0"

