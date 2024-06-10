# Set up links between Python/R (IRkernel, rpy2) and R/Python (reticulate)

ln -s /opt/conda/envs/gds/bin/jupyter /usr/local/bin
R -e "install.packages(c( \
        'IRkernel', 'reticulate' \
        ), repos='https://cran.rstudio.com'); \
      library(IRkernel); \
      IRkernel::installspec(displayname='gdsR-$GDS_ENV_VERSION');"
LD_LIBRARY_PATH /usr/local/lib/R/lib/:${LD_LIBRARY_PATH}
fix-permissions $HOME
fix-permissions $CONDA_DIR

sed -i "s/c.KernelSpecManager.whitelist = {'gds'}/c.KernelSpecManager.whitelist = {'gds', 'ir'}/g" \
    me/${NB_USER}/.jupyter/jupyter_lab_config.py

pip install -U --no-deps \
        rpy2 \
        rpy2-arrow \
        pytz \
        pytz_deprecation_shim \
        jinja2 \
        'cffi>=1.10.0' \
        tzlocal \
 && pip cache purge

rm -rf /home/$NB_USER/.cache/pip
rm -rf /tmp/downloaded_packages/ /tmp/*.rds

