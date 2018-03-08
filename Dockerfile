#FROM continuumio/miniconda3
FROM rocker/geospatial:latest

MAINTAINER Dani Arribas-Bel <D.Arribas-Bel@liverpool.ac.uk>

#---
# https://github.com/ContinuumIO/docker-images/blob/master/miniconda3/Dockerfile
ENV LANG=C.UTF-8 LC_ALL=C.UTF-8

RUN apt-get update --fix-missing && \
    apt-get install -y wget bzip2 ca-certificates curl git && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN echo 'export PATH=/opt/conda/bin:$PATH' > /etc/profile.d/conda.sh && \
    wget --quiet https://repo.continuum.io/miniconda/Miniconda3-4.4.10-Linux-x86_64.sh -O ~/miniconda.sh && \
    /bin/bash ~/miniconda.sh -b -p /opt/conda && \
    rm ~/miniconda.sh && \
    /opt/conda/bin/conda clean -tipsy

ENV TINI_VERSION v0.16.1
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /usr/bin/tini
RUN chmod +x /usr/bin/tini

ENV PATH /opt/conda/bin:$PATH
#---

WORKDIR /gds

ADD . /gds

# Force bash always
# https://github.com/pdonorio/dockerizing/blob/master/python/py3dataconda/Dockerfile
RUN rm /bin/sh && ln -s /bin/bash /bin/sh

RUN apt-get update && \
    install -y g++ gcc libreadline-dev

#RUN apt-get install -y pandoc texlive-full

#---
# Python
RUN conda update -y conda
RUN conda install -n base -c conda-forge jupyter_client

RUN conda-env create -f gds_stack.yml

#RUN R -e "source('install.R')"

#RUN source /opt/conda/bin/activate gds && \
#    R -e "devtools::install_github('IRkernel/IRkernel'); \
#          library(IRkernel); \
#          IRkernel::installspec();"

RUN conda clean -tipsy
#---

ENTRYPOINT [ "tini", "--" ]
CMD [ "/bin/bash" ]
#ENTRYPOINT [ "tini", "--" ]
#CMD [ "start.sh" ]

# Add local files as late as possible to avoid cache busting
COPY start.sh /usr/local/bin/

