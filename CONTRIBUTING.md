# Contributing

Issues and pull requests are welcome.

- **Bugs**: open an issue with the command you ran, `cowtree config` output, `git --version`, macOS version and
  the filesystem (`diskutil info / | grep Personality`).
- **Changes**: fork, branch, run `./test/smoke.sh`, open a PR. CI runs the same script on a macOS runner.
  Keep `bin/cowtree` bash 3.2 compatible and `lib/dedupe.py` dependency-free. New commands and config keys need
  a row in `README.md`.
- **Scope**: cowtree is a thin layer over `git worktree` and `clonefile`. Features that need a daemon, a
  virtual filesystem or a database belong in another project.
- **Linux / other filesystems**: the fallback is a plain copy today. A reflink (`cp --reflink`, btrfs/XFS) or
  overlayfs backend is the most wanted contribution; see the open issues.

By contributing you agree your work is released under the MIT License.
