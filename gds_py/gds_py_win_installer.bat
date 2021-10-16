REM Please run this from the Anaconda Prompt
REM This installer is pinned to the latest released version
REM Set up GDS environment
REM call conda env create -f https://github.com/darribas/gds_env/raw/v6.1/gds_py/gds_py.yml
call conda env create -f https://github.com/darribas/gds_env/raw/master/gds_py/gds_py.yml
REM Activate environment
call conda activate gds
REM Add pip packages
call conda install -y -c conda-forge git
REM pip install -r https://github.com/darribas/gds_env/raw/v6.1/gds_py/gds_py_pip.txt
pip install -r https://github.com/darribas/gds_env/raw/master/gds_py/gds_py_pip.txt
REM JupyterLab old plugin's
jupyter labextension install nbdime-jupyterlab --no-build
jupyter lab build -y
jupyter lab clean -y
conda clean --all -f -y
call conda deactivate
