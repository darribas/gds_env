#!/bin/bash
echo "Updating conda..."
/opt/conda/bin/conda update --yes conda 
echo "Installing conda geo-stack..."
conda install -c conda-forge -c defaults --quiet --yes \
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

# pip commands
echo "Installing pip geo-stack..."
pip install -U --no-deps bambi colorama geopy gitdb2 gitpython nbdime polyline pysal==2.0.0 pystan smmap2 tzlocal 

# Workaround until geopandas 0.5 released
echo "Temporary workaround until geopandas 0.5 is out..."
pip install -U --no-deps mapclassify git+git://github.com/geopandas/geopandas.git@master

# Enable widgets in Jupyter
/opt/conda/bin/jupyter labextension install @jupyter-widgets/jupyterlab-manager@0.38
# Enable ipyleaflet
/opt/conda/bin/jupyter labextension install jupyter-leaflet
# Enable qgrid
/opt/conda/bin/jupyter labextension install qgrid
# Enable nbdime
/opt/conda/bin/nbdime extensions --enable --user $NB_USER
/opt/conda/bin/jupyter labextension update nbdime-jupyterlab
# Clean up
conda clean -tipsy
npm cache clean --force
rm -rf $CONDA_DIR/share/jupyter/lab/staging
rm -rf /home/$NB_USER/.cache/yarn

#--- Jupyter config ---#
echo "c.NotebookApp.default_url = '/lab'" \
 >> /home/$NB_USER/.jupyter/jupyter_notebook_config.py


