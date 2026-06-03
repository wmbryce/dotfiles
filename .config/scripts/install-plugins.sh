#!/usr/bin/env bash
# Install/sync tmux + neovim plugins headlessly. Safe to re-run.
set -euo pipefail

# -- tmux / TPM ---------------------------------------------------------------
# Owns TPM end-to-end: clones it if missing, then installs every plugin declared
# in tmux.conf. Must run AFTER link.sh so ~/.tmux/plugins points at the repo dir.
if command -v tmux &>/dev/null; then
  TPM_DIR="$HOME/.tmux/plugins/tpm"
  # Clone TPM if absent or empty (a fresh checkout leaves only empty plugin dirs).
  if [[ ! -x "$TPM_DIR/bin/install_plugins" ]]; then
    echo "==> tmux: cloning TPM"
    rm -rf "$TPM_DIR"
    git clone --depth 1 https://github.com/tmux-plugins/tpm "$TPM_DIR"
  fi

  echo "==> tmux: TPM plugin install"
  # TPM reads TMUX_PLUGIN_MANAGER_PATH from the server env; the config's tpm run
  # line sets it, but export a fallback so install works even headlessly.
  export TMUX_PLUGIN_MANAGER_PATH="$HOME/.tmux/plugins/"
  tmux start-server
  tmux new-session -d -s __tpm_bootstrap 2>/dev/null || true
  "$TPM_DIR/bin/install_plugins" || true
  "$TPM_DIR/bin/update_plugins" all || true
  tmux kill-session -t __tpm_bootstrap 2>/dev/null || true
else
  echo "   tmux not found; skipping"
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
