FROM jupyter/minimal-notebook:2022-12-05

LABEL maintainer="Dani Arribas-Bel <D.Arribas-Bel@liverpool.ac.uk>"

# https://github.com/ContinuumIO/docker-images/blob/master/miniconda3/Dockerfile
ENV LANG=C.UTF-8 LC_ALL=C.UTF-8

#--- Python ---#

#RUN conda config --add channels conda-forge \
    #&& conda config --add channels pyviz \
    #&& conda config --set channel_priority strict \
    #&& mamba install --freeze-installed --yes --quiet \
RUN mamba install --yes --quiet \
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
     #'dask-kubernetes' \
     'dask-geopandas' \
     #'dask-ml' \ #  https://github.com/dask/dask-ml/issues/908
     'datashader' \
     'flake8' \
     'geocube' \
     'geopandas' \
     'geopy' \
     'gstools' \
     'h3-py' \
     'hdbscan' \
     'ipyleaflet' \
     'ipympl' \
     'ipywidgets' \
     'jupyter_bokeh' \
     'jupytext' \
     'legendgram' \
     'lxml' \
     'momepy' \
     'nbdime' \
     'nbsphinx' \
     'netCDF4' \
     'networkx' \
     'openpyxl' \
     'osmnx' \
     'palettable' \
     'pandana' \
     'pip' \
     'polyline' \
     'pooch' \
     'protobuf' \
     'psycopg2' \
     'pyarrow' \
     'pygeos' \
     'pyogrio' \
     'pyppeteer' \
     'pyrosm' \
     'pysal' \
     'pystac-client' \
     'python-duckdb' \
     'rasterio' \
     'rasterstats' \
     'rio-cogeo' \
     'rioxarray' \
     #'scikit-image' \
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
 && pip cache purge \
 && rm -rf /home/$NB_USER/.cache/pip \
 && rm ./gds_py_pip.txt

#--- Jupyter config ---#
USER root
# Clean cache up
RUN jupyter lab clean -y \
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
ENV GDS_ENV_VERSION "8.0"

# Switch back to user to avoid accidental container runs as root
USER $NB_UID


