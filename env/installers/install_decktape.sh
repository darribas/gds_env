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
 && apt-get autoremove -y \
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
# amd64-vs-arm64 divergence. Nothing is version-pinned — DeckTape and Chromium
# track latest (see the repo's "latest for tools" policy).
npm install -g decktape \
 && npm cache clean --force

PLAYWRIGHT_BROWSERS_PATH="$decktape_browser_dir" \
    npx --yes playwright@latest install chromium

# Resolve the Chromium binary by BINARY NAME, never by directory layout.
#
# Playwright's on-disk layout is not stable and has broken this script three
# times: `chromium-<rev>/chrome-linux/chrome` originally (db37712, 1c5282a),
# then Chrome-for-Testing builds as `chrome-linux64/` on amd64, and on
# 2026-09-08 Playwright moved arm64 to CfT too, giving `chrome-linux-arm64/`.
# Enumerating layouts loses that race by construction -- each new name is
# another silent `find` miss. The binary *names* have been stable throughout,
# so match those and let the directory be called whatever it likes.
find_browser_bin() {
    # `|| true`: under `pipefail` a non-zero find (e.g. a permission warning)
    # would otherwise abort the script via `set -e` on the assignment below.
    find "$decktape_browser_dir" -type f -perm -u+x -name "$1" 2>/dev/null \
        | sort | tail -n 1 || true
}

# Prefer the full browser; fall back to the headless shell under either of its
# names (CfT calls it chrome-headless-shell, Playwright's own builds headless_shell).
chrome_bin="$(find_browser_bin chrome)"
for candidate_name in chrome-headless-shell headless_shell; do
    [ -n "$chrome_bin" ] && break
    chrome_bin="$(find_browser_bin "$candidate_name")"
done

if [ -z "$chrome_bin" ]; then
    echo "ERROR: no Chromium binary found under $decktape_browser_dir" >&2
    echo "Playwright's layout has changed again. Actual contents:" >&2
    find "$decktape_browser_dir" -maxdepth 3 >&2
    exit 1
fi
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
