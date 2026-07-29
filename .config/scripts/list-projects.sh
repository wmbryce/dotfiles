#!/usr/bin/env bash

# Emit candidate project directories, one per line, for the tmux and herdr
# sessionizers. Both consume this so the two stay in sync.

set -uo pipefail

# Roots scanned for git repos. Repos nest unevenly (~/dev/cosmo-router,
# ~/dev/edu/skills, ~/dev/sb/frontend/sb-platform), so discovery is by .git
# rather than a fixed depth-1 listing.
SCAN_ROOTS=(
  "$HOME/dev"
)

# Dirs offered directly even though they are not repos themselves — ~/dev/sb is
# the workspace root for Steppingblocks work, where cross-repo context loads.
EXTRA_DIRS=(
  "$HOME/dev/sb"
  "$HOME/dotfiles"
  "$HOME/tex"
)

{
  for d in "${EXTRA_DIRS[@]}"; do
    [[ -d "$d" ]] && printf '%s\n' "$d"
  done

  for root in "${SCAN_ROOTS[@]}"; do
    [[ -d "$root" ]] || continue
    # -name .git matches both a repo's .git dir and a worktree's .git file.
    find "$root" -maxdepth 4 \
      \( -name node_modules -o -name .venv -o -name target -o -name dist \) -prune -o \
      -name .git -prune -print 2>/dev/null
  done | sed 's|/\.git$||'
} | awk 'NF && !seen[$0]++'
