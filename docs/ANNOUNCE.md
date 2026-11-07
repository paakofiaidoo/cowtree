# Launch copy

## Show HN
**Show HN: Cowtree – copy-on-write git worktrees for parallel AI coding sessions**

I run several Claude Code / Codex sessions on the same repo at once, one branch each. `git worktree add` shares
the object store but still writes a full copy of every checked-out file, and every worktree rebuilds
`node_modules`. On a nearly full laptop that was the limit on how many sessions I could run.

cowtree builds the worktree out of APFS `clonefile` copies of the main checkout instead (reflink on btrfs/XFS),
ignored build dirs included. A 704 MB checkout becomes a 3.5 MB worktree; editing a file costs that file. No
FUSE, no daemon: ~500 lines of bash plus a python helper, editors and compilers see ordinary files.

It also records which branch lives in which worktree in git config (`cowtree branches`, `cowtree which`), sweeps
merged worktrees, turns existing plain worktrees into clones (`cowtree adopt`, freed 787 MB on mine), and ships
as a Claude Code plugin + MCP server so agents use it instead of `git worktree add`.

https://github.com/paakofiaidoo/cowtree — MIT.

## X / Bluesky
Running 5 AI coding sessions on one repo? Each `git worktree` is a full copy + its own node_modules.

cowtree makes worktrees out of APFS clones instead: 704MB checkout → 3.5MB worktree. Ships as a Claude Code
plugin + MCP server. MIT.

github.com/paakofiaidoo/cowtree

## Reddit r/git, r/ClaudeAI, r/ChatGPTCoding
Title: cowtree: git worktrees that cost ~0 disk (APFS clonefile), built for running many AI sessions on one repo
Body: the Show HN text.
