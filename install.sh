#!/usr/bin/env bash
# Symlinks bin/cowtree into $PREFIX/bin (default ~/bin) and writes a default global config.
set -euo pipefail
HERE=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
PREFIX=${PREFIX:-$HOME}
CFG="${XDG_CONFIG_HOME:-$HOME/.config}/cowtree/config.toml"
mkdir -p "$PREFIX/bin"
ln -sfn "$HERE/bin/cowtree" "$PREFIX/bin/cowtree"
if [ ! -f "$CFG" ]; then
  mkdir -p "$(dirname "$CFG")"
  cat > "$CFG" <<TOML
# cowtree global config. Project cowtree.toml and flags override these.
wt_root = "~/dev/wt"
layout = "central"
editor = "code"
# exclude = ["build", ".dart_tool"]
TOML
  echo "wrote $CFG"
fi
echo "installed $PREFIX/bin/cowtree"
case ":$PATH:" in *":$PREFIX/bin:"*) ;; *) echo "add $PREFIX/bin to your PATH" ;; esac
command -v python3 >/dev/null || echo "python3 is required for dedupe/ls/status"
[ "$(uname)" = Darwin ] || echo "note: clonefile needs macOS/APFS; elsewhere cowtree falls back to full copies"
