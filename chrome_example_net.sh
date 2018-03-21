#!/bin/bash

set -euo pipefail

port=${1:-''}
headless=${2:-''}
data_dir=$(mktemp -d)

if [[ -z "$port" ]]; then
  echo "You must give a proxy port" >&2
  exit 1
fi

function finish {
  if [[ -n "$data_dir" && -d "$data_dir" ]]; then
    rm -rf "$data_dir"
  fi
}

"/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" \
  --disable-background-networking \
  --disable-client-side-phishing-detection \
  --disable-default-apps \
  --disable-gpu \
  --disable-hang-monitor \
  --disable-popup-blocking \
  --disable-prompt-on-repost \
  --disable-sync \
  --disable-web-resources \
  --disable-web-security \
  --enable-automation \
  --enable-logging \
  --force-fieldtrials=SiteIsolationExtensions/Control \
  "${headless}" \
  --ignore-certificate-errors \
  --log-level=0 \
  --metrics-recording-only \
  --no-first-run \
  --password-store=basic \
  "--proxy-server=127.0.0.1:${port}" \
  --test-type=webdriver \
  --use-mock-keychain \
  --user-data-dir="${data_dir}" \
  https://example.net

trap finish EXIT
