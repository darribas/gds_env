#!/bin/bash

########################
### Install Decktape ###
########################

# https://jupyterbook.org/advanced/pdf.html#build-a-pdf-from-your-book-html
# https://github.com/astefanutti/decktape/issues/187
apt-get update -qq \
 && apt-get install -y --no-install-recommends \
    libasound2t64 \
    libatk1.0-0t64 \
    libatk-bridge2.0-0t64 \
    libc6 \
    libcairo2 \
    libcups2t64 \
    libdbus-1-3 \
    libexpat1 \
    libfontconfig1 \
    libgcc-s1 \
    libgdk-pixbuf-2.0-0 \
    libglib2.0-0t64 \
    libgtk-3-0t64 \
    libnspr4 \
    libpango-1.0-0 \
    libpangocairo-1.0-0 \
    libstdc++6 \
    libx11-6 \
    libx11-xcb1 \
    libxcb1 \
    libxcomposite1 \
    libxcursor1 \
    libxdamage1 \
    libxext6 \
    libxfixes3 \
    libxi6 \
    libxrandr2 \
    libxrender1 \
    libxss1 \
    libxtst6 \
    ca-certificates \
    fonts-liberation \
    libgbm1 \
    libnss3 \
    lsb-release \
    unzip \
    xdg-utils \
    wget \
    libcairo2-dev \
    libasound2-dev \
    libpangocairo-1.0-0 \
    libx11-xcb-dev \
    libxcursor-dev \
    libxdamage-dev \
    libxi-dev \
    libxtst-dev \
    libxss-dev \
    libxrandr-dev \
 && rm -rf /var/lib/apt/lists/* \
 && apt-get autoclean \
 && apt-get autoremove \
 && apt-get clean

decktape_browser_dir=/opt/decktape-browser
decktape_browser_bin=/usr/local/bin/decktape-chrome

mkdir -p "$decktape_browser_dir"

mkdir $HOME/.decktape \
 && fix-permissions $HOME/.decktape

npm install -g decktape \
 && npm cache clean --force \
 && decktape_bin="$(command -v decktape)" \
 && decktape_real_bin="$(readlink -f "$decktape_bin")" \
 && decktape_package_dir="$(cd "$(dirname "$decktape_real_bin")" && pwd)" \
 && decktape_node_modules="$decktape_package_dir/node_modules" \
 && PUPPETEER_CACHE_DIR="$decktape_browser_dir" \
    node "$decktape_node_modules/puppeteer/install.mjs" \
 && echo "=== decktape browser cache ===" \
 && find "$decktape_browser_dir" | sort \
 && echo "==============================" \
 && decktape_bin_dir="$(dirname "$decktape_bin")" \
 && chmod -R a+rX "$decktape_browser_dir" \
 && chrome_bin="$(find "$decktape_browser_dir" -path '*/chrome-linux64/chrome' -type f | sort | tail -n 1)" \
 && if [[ -z "$chrome_bin" ]]; then \
      chrome_bin="$(find "$decktape_browser_dir" -path '*/chrome-headless-shell-linux64/chrome-headless-shell' -type f | sort | tail -n 1)"; \
    fi \
 && if [[ -z "$chrome_bin" ]]; then \
      chrome_zip="$(find "$decktape_browser_dir"/chrome -name '*-chrome-linux64.zip' -type f | sort | tail -n 1)"; \
      if [[ -n "$chrome_zip" ]]; then \
        mkdir -p "$decktape_browser_dir/manual-extract/chrome"; \
        unzip -oq "$chrome_zip" -d "$decktape_browser_dir/manual-extract/chrome"; \
        chrome_bin="$(find "$decktape_browser_dir/manual-extract/chrome" -path '*/chrome-linux64/chrome' -type f | sort | tail -n 1)"; \
      fi; \
    fi \
 && if [[ -z "$chrome_bin" ]]; then \
      headless_zip="$(find "$decktape_browser_dir"/chrome-headless-shell -name '*-chrome-headless-shell-linux64.zip' -type f | sort | tail -n 1)"; \
      if [[ -n "$headless_zip" ]]; then \
        mkdir -p "$decktape_browser_dir/manual-extract/chrome-headless-shell"; \
        unzip -oq "$headless_zip" -d "$decktape_browser_dir/manual-extract/chrome-headless-shell"; \
        chrome_bin="$(find "$decktape_browser_dir/manual-extract/chrome-headless-shell" -path '*/chrome-headless-shell-linux64/chrome-headless-shell' -type f | sort | tail -n 1)"; \
      fi; \
    fi \
 && test -n "$chrome_bin" \
 && printf 'Resolved DeckTape Chrome path: %s\n' "$chrome_bin" \
 && test -e "$chrome_bin" \
 && chmod a+rx "$chrome_bin" \
 && test -x "$chrome_bin" \
 && ln -sf "$chrome_bin" "$decktape_browser_bin" \
 && mv "$decktape_bin_dir/decktape" "$decktape_bin_dir/decktape.real" \
 && install -m 755 "$HOME/scripts/decktape_wrapper.sh" "$decktape_bin_dir/decktape"
