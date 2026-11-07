#!/usr/bin/env bash
# end-to-end: clone cost ~0, edits diverge, base untouched, config link, dedupe, rm
set -euo pipefail
CT=$(cd "$(dirname "$0")/.." && pwd)/bin/cowtree
T=$(mktemp -d "${TMPDIR:-/tmp}/cowtree.XXXX"); T=$(cd "$T" && pwd -P); trap 'rm -rf "$T"' EXIT
export COWTREE_WT_ROOT="$T/wt" COWTREE_CONFIG="$T/global.toml"
fail() { echo "FAIL $*"; exit 1; }
git init -q "$T/base"; cd "$T/base"
head -c 50000000 /dev/urandom > blob.bin; echo "hello" > a.txt; mkdir -p build; echo cache > build/out; echo build > .gitignore
git add -A; git -c user.name=t -c user.email=t@t commit -qm init
"$CT" config set wt_root "$T/wt" >/dev/null
"$CT" config set branch_prefix "feat/" --project "$T/base" >/dev/null
[ -f cowtree.toml ] || fail project-config
git add cowtree.toml; git -c user.name=t -c user.email=t@t commit -qm config
free() { df -k "$T" | tail -1 | awk '{print $4}'; }
b=$(free); W=$("$CT" add "$T/base" topic); a=$(free)
[ "$W" = "$T/wt/base-topic" ] || fail "dest $W"
[ "$(git -C "$W" branch --show-current)" = feat/topic ] || fail branch_prefix
[ -f "$W/build/out" ] || fail "ignored dir not cloned"
cmp -s "$W/blob.bin" blob.bin || fail content
delta=$((b-a)); [ $delta -lt 2048 ] || fail "clone cost ${delta}KB"
[ -z "$(git -C "$W" status --porcelain)" ] || fail dirty
grep -q "^base = \"$T/base\"" "$W/.cowtree.toml" || fail link
grep -qF "base      $T/base" <<<"$("$CT" status "$W")" || fail status
[ "$(git config --get branch.feat/topic.cowtree)" = "$W" ] || fail git-link
[ "$("$CT" which feat/topic "$T/base")" = "$W" ] || fail which
grep -qF "feat/topic" <<<"$("$CT" branches "$T/base")" || fail branches
echo change >> "$W/a.txt"; dd if=/dev/urandom of="$W/blob.bin" bs=1m count=1 conv=notrunc status=none
[ "$(cat a.txt)" = hello ] || fail base-changed
cmp -s "$W/blob.bin" blob.bin && fail blob-shared
[ "$(git -C "$W" status --porcelain | wc -l | tr -d ' ')" = 2 ] || fail status-count
git -C "$W" -c user.name=t -c user.email=t@t commit -qam edit
grep -q "a.txt" <<<"$("$CT" diff "$W" --stat)" || fail diff
# plain worktree → adopt (link + dedupe)
git worktree add -q "$T/wt/base-plain" -b plain >/dev/null 2>&1
p=$(free); grep -q "cloned 4 files" <<<"$("$CT" adopt "$T/wt/base-plain")" || fail adopt; q=$(free)
[ -f "$T/wt/base-plain/.cowtree.toml" ] || fail adopt-link
[ "$(git config --get branch.plain.cowtree)" = "$T/wt/base-plain" ] || fail adopt-git-link
[ $((q-p)) -gt 40000 ] || fail "dedupe freed only $((q-p))KB"
[ -z "$(git -C "$T/wt/base-plain" status --porcelain)" ] || fail dedupe-dirty
[ "$(grep -c "wt/base-" <<<"$("$CT" ls "$T/base")")" = 2 ] || fail ls
"$CT" workspace "$T/base" | xargs python3 -c 'import json,sys; d=json.load(open(sys.argv[1])); assert len(d["folders"])==3' || fail workspace
grep -q "keep .*feat/topic not merged" <<<"$("$CT" sweep "$T/base" --dry-run)" || fail sweep-keep
grep -q "would remove $T/wt/base-plain" <<<"$("$CT" sweep "$T/base" --dry-run)" || fail sweep-dry
grep -q "removed $T/wt/base-plain" <<<"$("$CT" sweep "$T/base")" || fail sweep
[ ! -e "$T/wt/base-plain" ] || fail sweep-rm
[ -z "$(git config --get branch.plain.cowtree)" ] || fail sweep-unlink
grep -q "kept branch feat/topic" <<<"$("$CT" rm "$W")" || fail rm-kept
[ ! -e "$W" ] || fail rm
[ -z "$(git config --get branch.feat/topic.cowtree)" ] || fail rm-unlink
echo "PASS clone cost ${delta}KB for $(du -sk . | cut -f1)KB checkout, dedupe freed $((q-p))KB"
