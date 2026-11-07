---
name: cowtree
description: Create, inspect and clean up copy-on-write git worktrees with the `cowtree` CLI. Use whenever a task needs its own branch or worktree, when several branches/PRs of one repository are worked on in parallel, when asked which worktree a branch lives in, or when worktrees need sweeping after merges. Never run plain `git worktree add` in a repo that uses cowtree.
---

# cowtree

`cowtree` makes a git worktree out of APFS/reflink clones of the base checkout, so a worktree costs disk only
for the files you change, build dirs included. Install check: `cowtree version` (install: `curl -fsSL https://raw.githubusercontent.com/paakofiaidoo/cowtree/main/install.sh | bash`).

## Rules
- One task = one worktree = one branch. The base checkout stays on its main branch and clean; never edit it.
- Start work: `cowtree add <base> <topic>` → prints the path; `cd` there and do everything inside it.
- Before touching a branch: `cowtree which <branch> <base>` or `cowtree branches <base>` to see where it is checked out.
- Finish: commit and push from the worktree; after the PR merges, `cowtree rm <worktree>` (or `cowtree sweep <base>`).
- Never commit `.cowtree.toml`; `cowtree.toml` in the project root is shared config and may be committed.

## Commands
| Need | Command |
|---|---|
| new worktree + branch | `cowtree add <base> <topic> [--from <ref>] [--branch <name>] [--exclude <dir>]` |
| where am I / how far from base | `cowtree status [<worktree>]`, `cowtree diff [<worktree>]` |
| branch → worktree | `cowtree branches <base>`, `cowtree which <branch> <base>` |
| list with disk cost | `cowtree ls <base>` / `cowtree ls --all` |
| take over a plain worktree | `cowtree adopt <worktree>` |
| reclaim space | `cowtree dedupe <worktree>` / `--all` |
| clean up merged | `cowtree sweep <base> [--dry-run]`, `cowtree rm <worktree>` |
| VS Code window per repo | `cowtree workspace <base> --open` |
| config | `cowtree config`, `cowtree config set <key> <value> [--project <base>]`, `cowtree init <base>` |

Config keys: `wt_root` (default `~/dev/wt`), `layout` (`central|sibling|inside`), `branch_prefix`, `editor`, `exclude`, `main_branch`;
env `COWTREE_<KEY>` overrides files. The branch↔worktree link is also in git: `git config --get-regexp 'branch\..*\.cowtree'`.
