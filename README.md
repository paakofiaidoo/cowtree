# cowtree

**Copy-on-write git worktrees.** One checkout per repo, as many parallel worktrees as you need, each costing
disk only for the files it changes. Built for AI coding sessions (Claude Code, Codex, Cursor, aider) that want
to work on several branches or PRs of the same repository at the same time, and just as usable by humans in
VS Code.

`git worktree add` already shares the object store, but it materialises a full second copy of every checked-out
file and leaves `node_modules`, `build/`, `.venv` to be rebuilt. `cowtree add` makes the worktree out of APFS
`clonefile` copies of the base checkout instead, ignored build directories included: a 704 MB checkout becomes
a 3.5 MB worktree, and editing a file costs the size of that file. Every editor, compiler and runtime sees
ordinary files, so nothing else changes.

```
$ cowtree add ~/code/myapp payments-retry
/Users/me/code/wt/myapp-payments-retry
$ cowtree ls ~/code/myapp
/Users/me/code/myapp  (base)
/Users/me/code/wt/myapp-payments-retry  [payments-retry]  logical 704.3MB  owned 8.0KB  base /Users/me/code/myapp
```

## Install

Requirements: macOS on APFS (clonefile), git ≥ 2.31, python3, bash ≥ 3.2. On other filesystems cowtree still
works but falls back to a plain copy and says so.

```bash
git clone https://github.com/<you>/cowtree.git ~/.cowtree && ~/.cowtree/install.sh
```

`install.sh` symlinks `bin/cowtree` into `~/bin` (or `$PREFIX/bin`) and writes a default
`~/.config/cowtree/config.toml`. Or run it from the clone: `./bin/cowtree`.

## Commands

| Command | What it does |
|---|---|
| `cowtree add <base> <topic> [--from <ref>] [--branch <name>] [--dest <path>] [--exclude <dir>]...` | Create a worktree of `<base>` at `<wt_root>/<repo>-<topic>` on branch `<topic>` (existing branch reused, new one cut from `--from`, default: the base's current branch). Clones every file and ignored dir except `--exclude`d ones. Prints the path. |
| `cowtree rm <worktree> [--force]` | Remove the worktree; delete its branch if already merged into the base, keep it otherwise. |
| `cowtree ls [<base>] \| --all` | Worktrees of one base, or every cowtree worktree under `wt_root`, with branch, logical size and bytes actually owned. |
| `cowtree status [<worktree>]` | Base, branch, ahead/behind the base, uncommitted changes, owned bytes. |
| `cowtree diff [<worktree>] [git-diff args]` | Diff of the worktree (committed + uncommitted) against the base's HEAD. |
| `cowtree dedupe <worktree> \| --all [--dry-run]` | Turn an existing plain worktree into a copy-on-write one: files byte-identical to the base become clones. Safe on dirty trees; modified files are left alone. |
| `cowtree workspace <base> [--open]` | Write `<wt_root>/<repo>.code-workspace` listing the base and every worktree as VS Code folders. |
| `cowtree code <worktree>` | Open the worktree in `editor`. |
| `cowtree init [<base>]` | Write a commented `cowtree.toml` into the project. |
| `cowtree config [--global \| --project <base> \| <worktree>]` | Show the resolved configuration and where each file lives. |
| `cowtree config set <key> <value> [--project <base>]` | Set a key in the global (default) or project config. |

## Configuration

Three files, most specific wins: flags › `<worktree>/.cowtree.toml` › `<base>/cowtree.toml` › `~/.config/cowtree/config.toml` › defaults.

| Key | Default | Meaning |
|---|---|---|
| `wt_root` | `~/dev/wt` | Where worktrees are created when `layout = "central"`. |
| `layout` | `central` | `central`: `<wt_root>/<repo>-<topic>`. `sibling`: next to the base, `<repo>-<topic>`. `inside`: `<base>/.cowtree/wt/<topic>` (added to the repo's `info/exclude`). |
| `branch_prefix` | empty | Prepended to `<topic>` for the branch name, e.g. `feat/`. |
| `editor` | `code` | Used by `code` and `workspace --open`. |
| `exclude` | `[]` | Directory names never cloned into a worktree, e.g. `["build", ".dart_tool"]`. |

`~/.config/cowtree/config.toml` is yours; `cowtree.toml` is committed with the project so every session and
every human gets the same layout; `.cowtree.toml` is written by `add` into each worktree and links it back to its
base (`base`, `repo`, `branch`, `from`, `created`). It is excluded from git via `info/exclude`, never committed,
and is what `status`, `diff`, `ls` and `dedupe` use to find the base. Override the global file with `COWTREE_CONFIG`.

## Working with AI sessions

One session, one worktree, one branch. The session master (or the human) runs `cowtree add <base> <topic>`,
starts the session inside the printed path, and the session commits and pushes its branch from there. The base
checkout stays on `main` and clean; nobody edits it directly. When the PR merges: `cowtree rm <worktree>`.
A `CLAUDE.md` / `AGENTS.md` in this repository tells agents the same thing.

## Working as a human on several repos

Worktrees are plain git worktrees, so VS Code, JetBrains and `git` itself see them as normal checkouts.
`cowtree workspace <base> --open` gives you one VS Code window with the base and every worktree of that repo
as separate folders; run it per repo and keep the `.code-workspace` files, they live in `wt_root`.

## How it works

1. `git worktree add --no-checkout` creates the worktree metadata and branch.
2. Every top-level entry of the base except `.git` is cloned with `cp -c -R` (APFS `clonefile`): zero bytes
   until a block is written, including `node_modules` and other ignored dirs.
3. `git read-tree HEAD` + `git update-index --refresh` populate the index without rewriting the clones; only
   files that differ between the base's checkout and the target ref are checked out from git.
4. `.cowtree.toml` is written and excluded.

`du` cannot see block sharing, so `ls` and `status` count a file as *owned* only when its size or mtime differs
from the same path in the base. For a true number use `df` before and after.

## Development

```bash
./test/smoke.sh     # end-to-end on a temp repo: clone cost, divergence, dedupe, rm
```

See `CONTRIBUTING.md`. Licensed under the MIT License.
