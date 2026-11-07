# cowtree — instructions for coding agents

This repository is the `cowtree` CLI (bash + a python helper). If you are an agent working *in a project that
uses cowtree*, the rules are:

- One session works in one worktree on one branch. Never edit the base checkout; it stays on `main` and clean.
- To start work on a new branch: `cowtree add <base-checkout> <topic>` and run everything inside the printed path.
- `cowtree status` tells you your base, branch and how far you are from it; `cowtree diff` shows your full change.
- `cowtree branches <base>` / `cowtree which <branch>` tell you which worktree a branch lives in before you touch it.
- Commit and push from the worktree as usual. When the PR is merged: `cowtree rm <worktree>`.
- Do not commit `.cowtree.toml`; `cowtree.toml` in the project root is shared config and may be committed.
- Space is not free because the files are clones: a build that rewrites `build/` owns every byte it writes.

The repo is also a Claude Code plugin (`.claude-plugin/`, `skills/cowtree`, `commands/`, `lib/mcp_server.py`);
`cowtree agent-install` wires it into Claude Code, Codex and Cursor.

If you are changing cowtree itself: keep `bin/cowtree` bash 3.2 compatible (macOS default), keep `lib/dedupe.py`
standard-library only, run `./test/smoke.sh` and `./test/mcp.sh` before you open a PR, and document every new command and key in
`README.md`.
