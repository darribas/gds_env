ARG base_image
FROM ${base_image}

USER root

RUN curl -fsSL https://code-server.dev/install.sh | sh

# latexmk is provided by the base gds image (env/installers/install_latex_tools.sh),
# which gds_code builds on top of — no need to install it again here.

RUN /usr/bin/code-server \
     --install-extension quarto.quarto \
     --install-extension vscodevim.vim \
     --install-extension ms-toolsai.jupyter \
     --install-extension ms-python.python \
     --install-extension james-yu.latex-workshop \
     --install-extension Catppuccin.catppuccin-vsc \
      && fix-permissions /home/$NB_USER/.local/share/code-server/

ENV QUARTO_PYTHON="/opt/conda/envs/gds/bin/python"

USER $NB_UID
EXPOSE 8080
ENTRYPOINT [ \
    "/usr/bin/code-server", \
    "--bind-addr", "0.0.0.0:8080", \
    "." \
]
