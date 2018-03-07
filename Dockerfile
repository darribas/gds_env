FROM continuumio/miniconda3

MAINTAINER Dani Arribas-Bel <D.Arribas-Bel@liverpool.ac.uk>

ENV LANG=C.UTF-8 LC_ALL=C.UTF-8

WORKDIR /gds

ADD . /gds

# Force bash always
# https://github.com/pdonorio/dockerizing/blob/master/python/py3dataconda/Dockerfile
RUN rm /bin/sh && ln -s /bin/bash /bin/sh

RUN apt-get install -y g++

#RUN apt-get install -y pandoc texlive-full

ENV PATH /opt/conda/bin:$PATH

RUN conda-env create -f gds_stack.yml

RUN source /opt/conda/bin/activate gds && \
    R -e "install.packages('tufte', dependencies=T, repos='http://cran.rstudio.com/'); \
         "

RUN conda clean -tipsy

ENTRYPOINT [ "tini", "--" ]
CMD [ "start.sh" ]

# Add local files as late as possible to avoid cache busting
COPY start.sh /usr/local/bin/

