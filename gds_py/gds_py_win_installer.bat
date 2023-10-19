REM Please run this from the Anaconda Prompt
REM This installer uses the latest version in master
REM Set up GDS environment
call conda env create -f https://raw.githubusercontent.com/darribas/gds_env/master/gds_py/gds_py.yml
REM JupyterLab old plugin's
call conda activate gds
jupyter labextension disable "@jupyterlab/apputils-extension:announcements"
conda clean --all -f -y
call conda deactivate
