---
description: Create a copy-on-write worktree and branch for a task, then work inside it
argument-hint: <topic> [base-checkout]
---
Create a worktree for `$ARGUMENTS` with cowtree:
1. Base = the second argument if given, else the root of the current git checkout (`git rev-parse --show-toplevel`); if that root is itself a worktree (`.cowtree.toml` exists), use its `base`.
2. Run `cowtree add <base> <topic>`; if the base is dirty, stop and show `git status` instead of stashing.
3. `cd` into the printed path for all further work in this session and report the path and branch in one line.
