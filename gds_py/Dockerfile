FROM jupyter/minimal-notebook:2022-05-09

LABEL maintainer="Dani Arribas-Bel <D.Arribas-Bel@liverpool.ac.uk>"

# https://github.com/ContinuumIO/docker-images/blob/master/miniconda3/Dockerfile
ENV LANG=C.UTF-8 LC_ALL=C.UTF-8

#--- Python ---#

#RUN conda config --add channels conda-forge \
    #&& conda config --add channels pyviz \
    #&& conda config --set channel_priority strict \
    #&& mamba install --freeze-installed --yes --quiet \
RUN mamba install --freeze-installed --yes -v \
     'conda-forge::blas=*=openblas' \
     'black' \
     #'bokeh' \
     'boto3' \
     'bottleneck' \
     'cenpy' \
     'clustergram' \
     'contextily' \
     'cython' \
     'dask' \
     #'dask-kubernetes' \
     'dask-ml' \
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
     #'jupyter_bokeh' \
     'jupytext' \
     'legendgram' \
     'lxml' \
     #'momepy==0.5.1' \ # Moved to pip
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
     'pyrosm' \
     ##############################
     # PySAL fix for https://github.com/pysal/pysal/issues/1234
     'pysal' \
#    'libpysal==4.5.1' \
#    'access==1.1.3' \
#    'esda==2.4.1' \
#    'giddy==2.3.3' \
#    'inequality==1.0.0' \
#    'pointpats==2.2.0' \
#    'segregation==2.1.0' \
#    'spaghetti==1.6.4' \
#    'mgwr==2.1.2' \
#    'spglm==1.0.8' \
#    'spint==1.0.7' \
#    'spreg==1.2.4' \
#    'spvcm==0.3.0' \
#    'tobler==0.8.2' \
#    'mapclassify==2.4.3' \
#    'splot==1.1.4' \
#    'spopt==0.1.2' \
     ##############################
     'pystac-client' \
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


