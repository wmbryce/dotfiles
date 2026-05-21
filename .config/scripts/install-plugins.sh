#!/usr/bin/env bash
# Install/sync tmux + neovim plugins headlessly. Safe to re-run.
set -euo pipefail

# -- tmux / TPM ---------------------------------------------------------------
if [[ -d "$HOME/.tmux/plugins/tpm" ]]; then
  echo "==> tmux: TPM plugin install"
  # TPM needs a tmux server running to load the config; spin a throwaway one.
  if command -v tmux &>/dev/null; then
    tmux start-server
    tmux new-session -d -s __tpm_bootstrap 2>/dev/null || true
    "$HOME/.tmux/plugins/tpm/bin/install_plugins" || true
    "$HOME/.tmux/plugins/tpm/bin/update_plugins" all || true
    tmux kill-session -t __tpm_bootstrap 2>/dev/null || true
  else
    echo "   tmux not found; skipping"
  fi
else
  echo "   TPM not installed; skipping (run bootstrap first)"
fi

# -- neovim / Lazy.nvim -------------------------------------------------------
if command -v nvim &>/dev/null; then
  echo "==> nvim: Lazy sync (plugins)"
  nvim --headless "+Lazy! sync" +qa 2>&1 | tail -5 || true

  echo "==> nvim: Treesitter parser update"
  nvim --headless "+TSUpdateSync" +qa 2>&1 | tail -5 || true

  echo "==> nvim: Mason registry update"
  nvim --headless "+MasonUpdate" +qa 2>&1 | tail -5 || true
else
  echo "   nvim not found; skipping"
fi

echo "==> plugin install done."
