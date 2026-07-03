#!/bin/bash

set -euo pipefail

wrapper_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
decktape_real="$wrapper_dir/decktape.real"
default_chrome_path="/usr/local/bin/decktape-chrome"

if [[ ! -x "$decktape_real" ]]; then
    echo "DeckTape binary not found at $decktape_real" >&2
    exit 1
fi

has_explicit_chrome_path=0
has_no_sandbox=0
has_disable_dev_shm_usage=0

for arg in "$@"; do
    if [[ "$arg" == "--chrome-path" || "$arg" == --chrome-path=* ]]; then
        has_explicit_chrome_path=1
    fi
    if [[ "$arg" == "--chrome-arg=--no-sandbox" ]]; then
        has_no_sandbox=1
    fi
    if [[ "$arg" == "--chrome-arg=--disable-dev-shm-usage" ]]; then
        has_disable_dev_shm_usage=1
    fi
done

extra_args=()

if [[ -f /.dockerenv ]]; then
    if [[ "$has_no_sandbox" -eq 0 ]]; then
        extra_args+=("--chrome-arg=--no-sandbox")
    fi
    if [[ "$has_disable_dev_shm_usage" -eq 0 ]]; then
        extra_args+=("--chrome-arg=--disable-dev-shm-usage")
    fi
fi

is_usable_browser() {
    local candidate_path="$1"

    if [[ ! -x "$candidate_path" ]]; then
        return 1
    fi

    if head -n 20 "$candidate_path" 2>/dev/null | grep -q 'snap install chromium'; then
        return 1
    fi

    return 0
}

chrome_path=""

if [[ "$has_explicit_chrome_path" -eq 0 ]]; then
    for candidate_path in \
        "${DECKTAPE_CHROME_PATH:-}" \
        "${PUPPETEER_EXECUTABLE_PATH:-}" \
        "$default_chrome_path"; do
        if [[ -n "$candidate_path" ]] && is_usable_browser "$candidate_path"; then
            chrome_path="$candidate_path"
            break
        fi
    done

    if [[ -z "$chrome_path" ]]; then
        for candidate in google-chrome google-chrome-stable chromium chromium-browser; do
            if command -v "$candidate" >/dev/null 2>&1; then
                candidate_path="$(command -v "$candidate")"
                if is_usable_browser "$candidate_path"; then
                    chrome_path="$candidate_path"
                    break
                fi
            fi
        done
    fi
fi

if [[ -n "$chrome_path" ]]; then
    exec "$decktape_real" --chrome-path "$chrome_path" "${extra_args[@]}" "$@"
fi

exec "$decktape_real" "${extra_args[@]}" "$@"
