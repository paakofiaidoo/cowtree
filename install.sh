#!/usr/bin/env bash
# Installs cowtree. Works from a clone (./install.sh) or via
#   curl -fsSL https://raw.githubusercontent.com/paakofiaidoo/cowtree/main/install.sh | bash
set -euo pipefail
PREFIX=${PREFIX:-$HOME}
COWTREE_HOME=${COWTREE_HOME:-$HOME/.cowtree}
CFG="${XDG_CONFIG_HOME:-$HOME/.config}/cowtree/config.toml"
SRC=$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" 2>/dev/null && pwd || true)
if [ -z "$SRC" ] || [ ! -x "$SRC/bin/cowtree" ]; then
  if [ -d "$COWTREE_HOME/.git" ]; then git -C "$COWTREE_HOME" pull -q --ff-only; else git clone -q https://github.com/paakofiaidoo/cowtree.git "$COWTREE_HOME"; fi
  SRC=$COWTREE_HOME
fi
mkdir -p "$PREFIX/bin"
ln -sfn "$SRC/bin/cowtree" "$PREFIX/bin/cowtree"
if [ ! -f "$CFG" ]; then
  mkdir -p "$(dirname "$CFG")"
  cat > "$CFG" <<TOML
# cowtree global config. Project cowtree.toml, COWTREE_<KEY> env and flags override these.
wt_root = "~/dev/wt"
layout = "central"
editor = "code"
# exclude = ["build", ".dart_tool"]
TOML
  echo "wrote $CFG"
fi
echo "installed $PREFIX/bin/cowtree -> $SRC ($("$SRC/bin/cowtree" version))"
case ":$PATH:" in *":$PREFIX/bin:"*) ;; *) echo "add $PREFIX/bin to your PATH" ;; esac
command -v python3 >/dev/null || echo "python3 is required for dedupe/ls/status and the MCP server"
[ "$(uname)" = Darwin ] || echo "note: needs APFS (macOS) or a reflink filesystem (btrfs/XFS) for zero-cost clones"
if [ "${COWTREE_AGENTS:-1}" != 0 ]; then "$SRC/bin/cowtree" agent-install all; fi
