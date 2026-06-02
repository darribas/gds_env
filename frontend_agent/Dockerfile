ARG base_image
FROM ${base_image}

USER root

#--- System tools agents reach for ---#
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
        ripgrep \
        fd-find \
        fzf \
 && ln -s "$(command -v fdfind)" /usr/local/bin/fd \
 && rm -rf /var/lib/apt/lists/*

#--- GitHub CLI (official apt repo) ---#
RUN mkdir -p -m 755 /etc/apt/keyrings \
 && curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
      -o /etc/apt/keyrings/githubcli-archive-keyring.gpg \
 && chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg \
 && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
      > /etc/apt/sources.list.d/github-cli.list \
 && apt-get update \
 && apt-get install -y --no-install-recommends gh \
 && rm -rf /var/lib/apt/lists/*

#--- Node 20 (NodeSource) for npm-based harnesses + LSPs ---#
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
 && apt-get install -y --no-install-recommends nodejs \
 && rm -rf /var/lib/apt/lists/*

#--- Agent harnesses + LSPs (system-wide via npm) ---#
RUN npm install -g \
        @anthropic-ai/claude-code \
        @github/copilot \
        bash-language-server \
        dockerfile-language-server-nodejs \
        markdown-language-server \
        pyright \
        typescript \
        typescript-language-server \
        vscode-langservers-extracted \
        yaml-language-server \
 && npm cache clean --force

#--- R language server (into the existing gds R env) ---#
RUN /opt/conda/envs/gds/bin/Rscript -e 'install.packages("languageserver", repos="https://cloud.r-project.org")'

#--- Notebook headless extras (into the gds python env) ---#
RUN /opt/conda/envs/gds/bin/pip install --no-cache-dir papermill jupytext

#--- Baked opencode config (user mount overrides) ---#
COPY opencode.json /home/${NB_USER}/.config/opencode/opencode.json
COPY tui.json /home/${NB_USER}/.config/opencode/tui.json
RUN chown -R ${NB_UID}:${NB_GID} /home/${NB_USER}/.config

USER ${NB_UID}
WORKDIR /home/${NB_USER}

# Put per-user bin dirs on PATH before running the install scripts so
# they don't warn about "not in PATH".
ENV PATH=/home/${NB_USER}/.opencode/bin:/home/${NB_USER}/.nb-cli/bin:${PATH}

#--- opencode (vendor install script, into user HOME) ---#
RUN curl -fsSL https://opencode.ai/install | bash

#--- nb-cli (jupyter-ai-contrib, into user HOME) ---#
RUN curl -fsSL https://raw.githubusercontent.com/jupyter-ai-contrib/nb-cli/main/install.sh | bash

#--- notebook-cli skill (fetched from upstream so it tracks latest) ---#
# opencode picks it up from ~/.config/opencode/skills/notebook-cli/
# Claude Code picks it up from ~/CLAUDE.md (parent of workdir)
RUN git clone --depth 1 https://github.com/jupyter-ai-contrib/nb-cli /tmp/nbcli \
 && mkdir -p /home/${NB_USER}/.config/opencode/skills \
 && cp -r /tmp/nbcli/skills/notebook-cli /home/${NB_USER}/.config/opencode/skills/ \
 && cp /tmp/nbcli/skills/notebook-cli/SKILL.md /home/${NB_USER}/CLAUDE.md \
 && rm -rf /tmp/nbcli

WORKDIR /home/${NB_USER}/work

ENTRYPOINT []
