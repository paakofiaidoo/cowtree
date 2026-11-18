#!/usr/bin/env bash
# Renders the launch images with headless Chrome: ./render.sh
set -euo pipefail
cd "$(dirname "$0")"
CHROME=${CHROME:-"/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"}
shot(){ "$CHROME" --headless=new --disable-gpu --hide-scrollbars --force-device-scale-factor=1 --window-size="$2" --screenshot="$3" "file://$PWD/$1" >/dev/null 2>&1; echo "$3"; }
shot og.html 1200,630 ../../../site/img/og.png
for f in 1-hero 2-proof 3-how 4-compare 5-agents; do shot "$f.html" 1270,760 "../gallery/$f.png"; done
shot thumbnail.html 240,240 ../gallery/thumbnail.png
