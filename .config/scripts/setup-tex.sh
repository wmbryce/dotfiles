#!/usr/bin/env bash
# Clone the tex repo (AI config: CLAUDE.md, skills, commands) and run its
# installer, which symlinks everything into ~/.claude/.
set -euo pipefail

TEX_REPO="${TEX_REPO:-https://github.com/wmbryce/tex.git}"
TEX_DIR="${TEX_DIR:-$HOME/tex}"

if [[ ! -d "$TEX_DIR" ]]; then
  echo "==> cloning tex into $TEX_DIR"
  git clone "$TEX_REPO" "$TEX_DIR"
else
  echo "==> tex already present at $TEX_DIR (skipping clone)"
fi

if [[ -x "$TEX_DIR/install.sh" ]]; then
  echo "==> running $TEX_DIR/install.sh"
  bash "$TEX_DIR/install.sh"
else
  echo "!! $TEX_DIR/install.sh missing or not executable; skipping" >&2
fi
