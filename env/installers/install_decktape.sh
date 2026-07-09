#!/bin/bash

set -euo pipefail

########################
### Install Decktape ###
########################

# https://jupyterbook.org/advanced/pdf.html#build-a-pdf-from-your-book-html
# https://github.com/astefanutti/decktape/issues/187
#
# Runtime shared libraries Chromium links against. These are the *runtime*
# packages only — Chrome needs the .so libraries, not the -dev headers, so no
# `*-dev` packages are installed here (audit 1.3).
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
    xdg-utils \
    wget \
 && rm -rf /var/lib/apt/lists/* \
 && apt-get autoclean \
 && apt-get autoremove \
 && apt-get clean

decktape_browser_dir=/opt/decktape-browser
decktape_browser_bin=/usr/local/bin/decktape-chrome

mkdir -p "$decktape_browser_dir"

mkdir "$HOME/.decktape" \
 && fix-permissions "$HOME/.decktape"

# Install DeckTape (latest) plus a Chromium for it.
#
# We fetch Chromium with Playwright on BOTH architectures. Playwright ships
# prebuilt Linux Chromium for amd64 and arm64, so this replaces the old per-arch
# puppeteer(amd64)/playwright(arm64) split — a source of the historical
# amd64-vs-arm64 divergence. Playwright installs into a deterministic layout,
# `$PLAYWRIGHT_BROWSERS_PATH/chromium-<rev>/chrome-linux/chrome`, so a single
# glob resolves the binary; the previous find-cascade + zip fallbacks are gone.
# Nothing is version-pinned — DeckTape and Chromium track latest (see the
# repo's "latest for tools" policy); robustness comes from the deterministic
# install path, not from a pin.
npm install -g decktape \
 && npm cache clean --force

PLAYWRIGHT_BROWSERS_PATH="$decktape_browser_dir" \
    npx --yes playwright@latest install chromium

chrome_bin="$(ls -d "$decktape_browser_dir"/chromium-*/chrome-linux/chrome | sort | tail -n 1)"
test -n "$chrome_bin"
test -x "$chrome_bin"
printf 'Resolved DeckTape Chrome path: %s\n' "$chrome_bin"

chmod -R a+rX "$decktape_browser_dir"
ln -sf "$chrome_bin" "$decktape_browser_bin"

# Swap the DeckTape entrypoint for our wrapper (injects --no-sandbox /
# --disable-dev-shm-usage inside Docker and resolves the browser path).
decktape_bin="$(command -v decktape)"
decktape_bin_dir="$(dirname "$decktape_bin")"
mv "$decktape_bin_dir/decktape" "$decktape_bin_dir/decktape.real"
install -m 755 "$HOME/scripts/decktape_wrapper.sh" "$decktape_bin_dir/decktape"

# In-layer permission fix: the npm global install lands in the conda prefix and
# the browser under /opt; fix what we touched here so no later pass copies the
# conda tree up (audit 1.1 hygiene).
fix-permissions "${CONDA_DIR}" "${HOME}"
