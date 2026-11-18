---
description: Reset this worktree's git-ignored build files to copy-on-write clones of the base's
argument-hint: [worktree] [--untracked]
---
Run `cowtree clear $ARGUMENTS --dry-run` (default worktree: the current directory) and show the plan verbatim. Then ask
before running it without `--dry-run`. Pass `--untracked` only if the user asked for untracked, non-ignored files to be reset too.
