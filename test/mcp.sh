#!/usr/bin/env bash
set -euo pipefail
HERE=$(cd "$(dirname "$0")/.." && pwd)
out=$(printf '%s\n' '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{}}' '{"jsonrpc":"2.0","id":2,"method":"tools/list"}' '{"jsonrpc":"2.0","id":3,"method":"tools/call","params":{"name":"cowtree_config","arguments":{}}}' | python3 "$HERE/lib/mcp_server.py")
python3 - "$out" <<'PY'
import json, sys
lines=[json.loads(l) for l in sys.argv[1].splitlines() if l.strip()]
assert lines[0]["result"]["serverInfo"]["name"]=="cowtree"
assert len(lines[1]["result"]["tools"])==10
assert "wt_root" in lines[2]["result"]["content"][0]["text"] and not lines[2]["result"]["isError"]
print("PASS mcp: initialize, 10 tools, tools/call")
PY
