FROM rocker/geospatial:latest

MAINTAINER Dani Arribas-Bel <D.Arribas-Bel@liverpool.ac.uk>

#---
# https://github.com/ContinuumIO/docker-images/blob/master/miniconda3/Dockerfile
ENV LANG=C.UTF-8 LC_ALL=C.UTF-8

RUN apt-get update --fix-missing && \
    apt-get install -y wget bzip2 ca-certificates curl git g++ gcc \
    libreadline-dev && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN /usr/local/bin/tlmgr install \
    a4wide adjustbox ae algorithms appendix babel-english bbm-macros beamer breakurl \
    catoptions charter cite cleveref collectbox colortbl comment courier dvips eepic \
    enumitem eso-pic eurosym extsizes fancyhdr float floatrow fontaxes \
    hardwrap helvetic inconsolata koma-script lastpage lettrine libertine \
    lipsum listings ltxkeys ly1 mathalfa mathpazo mathtools mdframed mdwtools \
    microtype morefloats ms multirow mweights ncntrsbk needspace newtx \
    ntgclass palatino parskip pbox pdfpages pgf picinpar preprint preview \
    psnfss roboto sectsty setspace siunitx srcltx standalone stmaryrd sttools \
    subfig subfigure symbol tabu tex textcase threeparttable thumbpdf times \
    titlesec tufte-latex ucs ulem units varwidth vmargin wallpaper wrapfig \
    xargs xcolor xstring xwatermark

ENV TINI_VERSION v0.16.1
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /usr/bin/tini
RUN chmod +x /usr/bin/tini

ENV PATH /opt/conda/bin:$PATH
#---
# Configure environment
# https://github.com/jupyter/docker-stacks/blob/master/base-notebook/Dockerfile
ENV CONDA_DIR=/opt/conda \
    SHELL=/bin/bash \
    NB_USER=gdser \
    NB_UID=1001 \
    NB_GID=102 \
    LC_ALL=en_US.UTF-8 \
    LANG=en_US.UTF-8 \
    LANGUAGE=en_US.UTF-8 \
    TERM=xterm-color
ENV PATH=$CONDA_DIR/bin:$PATH \
    HOME=/home/$NB_USER

# Create user with UID=1000 and in the 'users' group
# and make sure these dirs are writable by the `users` group.
RUN useradd -m -s /bin/bash -N -u $NB_UID $NB_USER && \
    mkdir -p $CONDA_DIR && \
    chown $NB_USER:$NB_GID $CONDA_DIR && \
    chmod g+w /etc/passwd /etc/group 

# User set up for RStudio
RUN echo "gdser:gdser" | chpasswd
RUN usermod -a -G staff $NB_USER
RUN usermod -a -G rstudio $NB_USER

# Install conda as user and check the md5 sum provided on the download site
ENV MINICONDA_VERSION 4.3.30
RUN cd /tmp && \
    wget --quiet https://repo.continuum.io/miniconda/Miniconda3-${MINICONDA_VERSION}-Linux-x86_64.sh && \
    echo "0b80a152332a4ce5250f3c09589c7a81 *Miniconda3-${MINICONDA_VERSION}-Linux-x86_64.sh" | md5sum -c - && \
    /bin/bash Miniconda3-${MINICONDA_VERSION}-Linux-x86_64.sh -f -b -p $CONDA_DIR && \
    rm Miniconda3-${MINICONDA_VERSION}-Linux-x86_64.sh && \
    $CONDA_DIR/bin/conda config --system --prepend channels conda-forge && \
    $CONDA_DIR/bin/conda config --system --set auto_update_conda false && \
    $CONDA_DIR/bin/conda config --system --set show_channel_urls true && \
    $CONDA_DIR/bin/conda update --all --quiet --yes && \
    conda clean -tipsy && \
    rm -rf $HOME/.cache/yarn 
#---
RUN mkdir $HOME/env
ADD . $HOME/env

#---
# Python
RUN conda update -y conda
RUN conda-env create -f $HOME/env/gds_stack.yml
RUN conda clean -tipsy
#---
# R

WORKDIR $HOME
RUN R -e "source('env/install.R')"
RUN ln -s /opt/conda/envs/gds/bin/jupyter /usr/local/bin
RUN R -e "library(devtools); \
          devtools::install_github('IRkernel/IRkernel'); \
          library(IRkernel); \
          IRkernel::installspec(prefix='/opt/conda/envs/gds/');"
ENV LD_LIBRARY_PATH /usr/local/lib/R/lib/:${LD_LIBRARY_PATH}
#----------
# Decktapte
#----------
RUN apt-get update --fix-missing && \
    apt-get install -y gnupg gnupg2 gnupg1 && \
    curl -sL https://deb.nodesource.com/setup_8.x | sudo -E bash - && \
    apt-get install -y nodejs 
RUN git clone https://github.com/astefanutti/decktape.git $HOME/decktape
WORKDIR $HOME/decktape

RUN npm install && \
    rm -rf node_modules/hummus/src && \
    rm -rf node_modules/hummus/build
RUN echo "\n #/bin/bash \
          \n /usr/bin/node /usr/local/etc/decktape/decktape.js --no-sandbox $* \
          " >> /usr/local/bin/decktape && \
    mv $HOME/decktape /usr/local/etc/
# Enable widgets in Jupyter
RUN /opt/conda/envs/gds/bin/jupyter labextension install @jupyter-widgets/jupyterlab-manager
#---


EXPOSE 8787
WORKDIR $HOME

ENTRYPOINT [ "tini", "--" ]
CMD [ "start.sh" ]

# Add local files as late as possible to avoid cache busting
COPY start.sh /usr/local/bin/
COPY start_jupyterlab /usr/local/bin
COPY start_rstudio /usr/local/bin
RUN chmod +x /usr/local/bin/start_jupyterlab
RUN chmod +x /usr/local/bin/start_rstudio
RUN chmod +x /usr/local/bin/decktape
RUN chmod 777 /usr/local/bin/start_jupyterlab
RUN chmod 777 /usr/local/bin/start_rstudio
RUN chmod 777 /usr/local/bin/decktape

