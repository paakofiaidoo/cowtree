---
description: Remove worktrees whose branch is merged and whose tree is clean
argument-hint: [base-checkout | --all]
---
Run `cowtree sweep $ARGUMENTS --dry-run` first and show the list. Then ask before running `cowtree sweep $ARGUMENTS` for real; never pass `--force`.
