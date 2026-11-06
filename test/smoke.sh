#!/usr/bin/env bash
# end-to-end: clone cost ~0, edits diverge, base untouched, rm cleans up
set -euo pipefail
CT=$(cd "$(dirname "$0")/.." && pwd)/bin/cowtree
T=$(mktemp -d "${TMPDIR:-/tmp}/cowtree.XXXX"); trap 'rm -rf "$T"' EXIT
export COWTREE_WT_ROOT="$T/wt"
git init -q "$T/base"; cd "$T/base"
head -c 50000000 /dev/urandom > blob.bin; echo "hello" > a.txt; mkdir -p build; echo cache > build/out; echo build > .gitignore
git add -A; git -c user.name=t -c user.email=t@t commit -qm init
free() { df -k "$T" | tail -1 | awk '{print $4}'; }
b=$(free); W=$("$CT" add "$T/base" topic); a=$(free)
[ -f "$W/build/out" ] || { echo "FAIL ignored dir not cloned"; exit 1; }
[ "$(cmp "$W/blob.bin" blob.bin && echo same)" = same ] || { echo FAIL content; exit 1; }
delta=$((b-a)); [ $delta -lt 2048 ] || { echo "FAIL clone cost ${delta}KB"; exit 1; }
[ -z "$(git -C "$W" status --porcelain)" ] || { echo FAIL dirty; exit 1; }
echo change >> "$W/a.txt"; dd if=/dev/urandom of="$W/blob.bin" bs=1m count=1 conv=notrunc status=none
[ "$(cat a.txt)" = hello ] || { echo FAIL base-changed; exit 1; }
cmp -s "$W/blob.bin" blob.bin && { echo FAIL blob-shared; exit 1; }
[ "$(git -C "$W" status --porcelain | wc -l | tr -d ' ')" = 2 ] || { echo FAIL status; exit 1; }
git -C "$W" -c user.name=t -c user.email=t@t commit -qam edit
"$CT" rm "$W" | grep -q "kept branch topic"
[ ! -e "$W" ] || { echo FAIL rm; exit 1; }
git branch --list topic | grep -q topic
echo "PASS clone cost ${delta}KB for $(du -sk . | cut -f1)KB checkout"
