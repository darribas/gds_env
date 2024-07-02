FROM gds:11.0alpha

USER root

RUN curl -fsSL https://code-server.dev/install.sh | sh

RUN apt-get update \
 && apt-get install -y latexmk

RUN /usr/bin/code-server \
     --install-extension quarto.quarto \
     --install-extension vscodevim.vim \
     --install-extension ms-toolsai.jupyter \
     --install-extension ms-python.python \
     --install-extension james-yu.latex-workshop \
     --install-extension equinusocio.vsc-material-theme \
      && fix-permissions /home/$NB_USER/.local/share/code-server/

ENV QUARTO_PYTHON="/opt/conda/envs/gds/bin/python"

USER $NB_UID
EXPOSE 8080
ENTRYPOINT [ \
    "/usr/bin/code-server", \
    "--bind-addr", "0.0.0.0:8080", \
    "." \
]
