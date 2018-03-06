# This is a slight modification from
# https://github.com/ContinuumIO/docker-images/blob/master/miniconda3/Dockerfile
FROM debian:8.5

MAINTAINER Kamil Kwiek <kamil.kwiek@continuum.io>

ENV LANG=C.UTF-8 LC_ALL=C.UTF-8

WORKDIR /gds

ADD . /gds

RUN apt-get update --fix-missing && apt-get install -y wget bzip2 ca-certificates \
    libglib2.0-0 libxext6 libsm6 libxrender1 \
    git mercurial subversion

RUN echo 'export PATH=/opt/conda/bin:$PATH' > /etc/profile.d/conda.sh && \
    wget --quiet https://repo.continuum.io/miniconda/Miniconda3-4.3.27-Linux-x86_64.sh -O ~/miniconda.sh && \
    /bin/bash ~/miniconda.sh -b -p /opt/conda && \
    rm ~/miniconda.sh

RUN apt-get install -y curl grep sed dpkg && \
    TINI_VERSION=`curl https://github.com/krallin/tini/releases/latest | grep -o "/v.*\"" | sed 's:^..\(.*\).$:\1:'` && \
    curl -L "https://github.com/krallin/tini/releases/download/v${TINI_VERSION}/tini_${TINI_VERSION}.deb" > tini.deb && \
    dpkg -i tini.deb && \
    rm tini.deb && \
    apt-get clean

RUN apt-get install -y g++

#RUN apt-get install -y pandoc texlive-full

ENV PATH /opt/conda/bin:$PATH

RUN conda-env create -f gds_stack.yml
RUN conda clean -tipsy

RUN source activate gds && \
    R CMD INSTALL tufte

ENTRYPOINT [ "tini", "--" ]
CMD [ "start.sh" ]

# Add local files as late as possible to avoid cache busting
COPY start.sh /usr/local/bin/

