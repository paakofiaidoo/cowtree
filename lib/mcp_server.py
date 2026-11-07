"""Minimal MCP (stdio, JSON-RPC 2.0) server exposing the cowtree CLI as tools. Standard library only.
Register: claude mcp add cowtree -- python3 /path/to/cowtree/lib/mcp_server.py
"""
import json, os, subprocess, sys

HERE = os.path.dirname(os.path.abspath(__file__))
CLI = os.path.join(HERE, "..", "bin", "cowtree")
PROTOCOL = "2024-11-05"

def S(desc, props, required):
    return {"description": desc, "inputSchema": {"type": "object", "properties": props, "required": required}}

P = lambda d: {"type": "string", "description": d}
TOOLS = {
    "cowtree_add": S("Create a copy-on-write worktree and branch for a task. Returns the worktree path; do all work for that task inside it.",
                     {"base": P("path of the base checkout"), "topic": P("short topic; becomes the branch name and the dir suffix"),
                      "from_ref": P("ref to branch from (default: base's current branch)"), "branch": P("explicit branch name"),
                      "exclude": {"type": "array", "items": {"type": "string"}, "description": "dir names not to clone"}}, ["base", "topic"]),
    "cowtree_rm": S("Remove a worktree; deletes its branch only if merged.", {"worktree": P("worktree path"), "force": {"type": "boolean"}}, ["worktree"]),
    "cowtree_ls": S("List worktrees of a base (or all) with branch and owned disk.", {"base": P("base checkout path; omit for --all")}, []),
    "cowtree_status": S("Base, branch, ahead/behind and disk cost of a worktree.", {"worktree": P("worktree path")}, ["worktree"]),
    "cowtree_diff": S("Diff of a worktree against its base HEAD (committed + uncommitted).", {"worktree": P("worktree path"), "stat_only": {"type": "boolean"}}, ["worktree"]),
    "cowtree_branches": S("Map every local branch of a base to the worktree it is checked out in.", {"base": P("base checkout path")}, ["base"]),
    "cowtree_which": S("Worktree path for a branch.", {"branch": P("branch name"), "base": P("base checkout path")}, ["branch", "base"]),
    "cowtree_adopt": S("Link and dedupe an existing plain git worktree.", {"worktree": P("worktree path")}, ["worktree"]),
    "cowtree_sweep": S("Remove worktrees whose branch is merged and tree clean. Always dry-run first.", {"base": P("base checkout path; omit for --all"), "dry_run": {"type": "boolean"}}, []),
    "cowtree_config": S("Show resolved configuration.", {"path": P("worktree path, or omit for global")}, []),
}

def run(args):
    r = subprocess.run([CLI, *args], capture_output=True, text=True)
    out = (r.stdout + ("\n" + r.stderr if r.stderr.strip() else "")).strip()
    return out or "(no output)", r.returncode != 0

def call(name, a):
    if name == "cowtree_add":
        args = ["add", a["base"], a["topic"]]
        if a.get("from_ref"): args += ["--from", a["from_ref"]]
        if a.get("branch"): args += ["--branch", a["branch"]]
        for e in a.get("exclude") or []: args += ["--exclude", e]
    elif name == "cowtree_rm": args = ["rm", a["worktree"]] + (["--force"] if a.get("force") else [])
    elif name == "cowtree_ls": args = ["ls", a.get("base") or "--all"]
    elif name == "cowtree_status": args = ["status", a["worktree"]]
    elif name == "cowtree_diff": args = ["diff", a["worktree"]] + (["--stat"] if a.get("stat_only") else [])
    elif name == "cowtree_branches": args = ["branches", a["base"]]
    elif name == "cowtree_which": args = ["which", a["branch"], a["base"]]
    elif name == "cowtree_adopt": args = ["adopt", a["worktree"]]
    elif name == "cowtree_sweep": args = ["sweep", a.get("base") or "--all"] + (["--dry-run"] if a.get("dry_run", True) else [])
    elif name == "cowtree_config": args = ["config"] + ([a["path"]] if a.get("path") else [])
    else: return f"unknown tool {name}", True
    return run(args)

def reply(id_, result=None, error=None):
    msg = {"jsonrpc": "2.0", "id": id_}
    if error: msg["error"] = error
    else: msg["result"] = result
    sys.stdout.write(json.dumps(msg) + "\n"); sys.stdout.flush()

def main():
    for line in sys.stdin:
        line = line.strip()
        if not line: continue
        try: req = json.loads(line)
        except ValueError: continue
        m, id_, p = req.get("method"), req.get("id"), req.get("params") or {}
        if m == "initialize":
            reply(id_, {"protocolVersion": PROTOCOL, "capabilities": {"tools": {}}, "serverInfo": {"name": "cowtree", "version": "0.4.0"}})
        elif m == "tools/list":
            reply(id_, {"tools": [{"name": n, **t} for n, t in TOOLS.items()]})
        elif m == "tools/call":
            text, err = call(p.get("name"), p.get("arguments") or {})
            reply(id_, {"content": [{"type": "text", "text": text}], "isError": err})
        elif m == "ping":
            reply(id_, {})
        elif id_ is not None:
            reply(id_, error={"code": -32601, "message": f"method not found: {m}"})

if __name__ == "__main__":
    main()
