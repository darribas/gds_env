FROM rocker/geospatial:latest

MAINTAINER Dani Arribas-Bel <D.Arribas-Bel@liverpool.ac.uk>

USER root

#---
# https://github.com/ContinuumIO/docker-images/blob/master/miniconda3/Dockerfile
ENV LANG=C.UTF-8 LC_ALL=C.UTF-8

RUN apt-get update --fix-missing && \
    apt-get install -y wget bzip2 ca-certificates curl git g++ gcc libreadline-dev && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

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
    LANGUAGE=en_US.UTF-8
ENV PATH=$CONDA_DIR/bin:$PATH \
    HOME=/home/$NB_USER

ADD fix-permissions /usr/local/bin/fix-permissions
# Create user with UID=1000 and in the 'users' group
# and make sure these dirs are writable by the `users` group.
RUN useradd -m -s /bin/bash -N -u $NB_UID $NB_USER && \
    mkdir -p $CONDA_DIR && \
    chown $NB_USER:$NB_GID $CONDA_DIR && \
    chmod g+w /etc/passwd /etc/group 
#   fix-permissions $HOME && \
#   fix-permissions $CONDA_DIR

RUN addgroup $NB_USER staff
RUN addgroup $NB_USER rstudio
# User set up for RStudio
RUN echo "gdser:gdser" | chpasswd
RUN usermod -a -G staff $NB_USER
RUN usermod -a -G rstudio $NB_USER

USER $NB_UID

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
    rm -rf /home/$NB_USER/.cache/yarn 
#   fix-permissions $CONDA_DIR && \
#   fix-permissions /home/$NB_USER
#---
WORKDIR $HOME

RUN mkdir $HOME/env
ADD . $HOME/env

#---
# Python
RUN conda update -y conda
RUN conda-env create -f $HOME/env/gds_stack.yml
RUN conda clean -tipsy
#---
# R

USER root

#   RUN R -e "source('install.R')"
#   RUN ln -s /opt/conda/envs/gds/bin/jupyter /usr/local/bin
#   RUN R -e "library(devtools); \
#             devtools::install_github('IRkernel/IRkernel'); \
#             library(IRkernel); \
#             IRkernel::installspec(prefix='/opt/conda/envs/gds/');"
#   ENV LD_LIBRARY_PATH /usr/local/lib/R/lib/:${LD_LIBRARY_PATH}
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
RUN chmod 777 /usr/local/bin/start_jupyterlab
RUN chmod 777 /usr/local/bin/start_rstudio

USER $NB_UID
