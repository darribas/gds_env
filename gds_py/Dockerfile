# Ubuntu Bionic 18.04 at Jan 26'19
FROM jupyter/minimal-notebook:87210526f381

MAINTAINER Dani Arribas-Bel <D.Arribas-Bel@liverpool.ac.uk>

# https://github.com/ContinuumIO/docker-images/blob/master/miniconda3/Dockerfile
ENV LANG=C.UTF-8 LC_ALL=C.UTF-8

#--- Python ---#

ADD install_gds_py.sh $HOME/install_gds_py.sh

USER root
RUN chmod +x $HOME/install_gds_py.sh

USER $NB_UID

RUN sed -i -e 's/\r$//' $HOME/install_gds_py.sh
RUN ["/bin/bash", "-c", "$HOME/install_gds_py.sh"]
RUN rm /home/jovyan/install_gds_py.sh 

# Switch back to user to avoid accidental container runs as root
USER $NB_UID

