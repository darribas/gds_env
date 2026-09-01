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

# None of gh/npm/curl-installer below pin a version, so an unchanged
# Dockerfile is a cache hit even when upstream has shipped a newer release.
# Bust the cache for everything below on every build (Makefile passes
# --build-arg CACHEBUST=$(date +%s)) so harnesses always install latest.
ARG CACHEBUST=1
RUN echo "cachebust=${CACHEBUST}" > /dev/null

# Three of the installs below are `curl ... | bash`. Without pipefail the
# pipeline reports bash's status, so a failed download yields a successful
# layer and a missing tool (hadolint DL4006).
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

#--- GitHub CLI (official apt repo) ---#
# `mkdir -p -m` only applies the mode to the deepest directory (SC2174),
# so set it explicitly.
RUN mkdir -p /etc/apt/keyrings \
 && chmod 755 /etc/apt/keyrings \
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

#--- Baked opencode config (user mount overrides) ---#
COPY opencode.json /home/${NB_USER}/.config/opencode/opencode.json
COPY tui.json /home/${NB_USER}/.config/opencode/tui.json
COPY skills/opencode-models /home/${NB_USER}/.config/opencode/skills/opencode-models
RUN chown -R ${NB_UID}:${NB_GID} /home/${NB_USER}/.config

#--- Baked Claude Code settings (user mount overrides) ---#
# No PATH override here: nb-cli's bin dir is already on PATH via the ENV line
# below, and a host-only PATH override (e.g. for bare-metal Claude) would not
# resolve inside the container.
RUN mkdir -p /home/${NB_USER}/.claude
COPY claude-settings.json /home/${NB_USER}/.claude/settings.json
RUN chown -R ${NB_UID}:${NB_GID} /home/${NB_USER}/.claude

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
# Claude Code has no discoverable skills/ dir here, so both notebook-cli
# and any repo-authored skills (see frontend_agent/skills/) get
# concatenated into the single always-loaded ~/CLAUDE.md instead. The
# second skill's frontmatter is stripped so it doesn't leave a stray
# YAML block mid-file.
RUN git clone --depth 1 https://github.com/jupyter-ai-contrib/nb-cli /tmp/nbcli \
 && mkdir -p /home/${NB_USER}/.config/opencode/skills \
 && cp -r /tmp/nbcli/skills/notebook-cli /home/${NB_USER}/.config/opencode/skills/ \
 && cp /tmp/nbcli/skills/notebook-cli/SKILL.md /home/${NB_USER}/CLAUDE.md \
 && rm -rf /tmp/nbcli \
 && printf '\n\n' >> /home/${NB_USER}/CLAUDE.md \
 && awk 'BEGIN{n=0} /^---$/{n++; next} n<2{next} {print}' \
      /home/${NB_USER}/.config/opencode/skills/opencode-models/SKILL.md \
      >> /home/${NB_USER}/CLAUDE.md

WORKDIR /home/${NB_USER}/work

ENTRYPOINT []
