#!/usr/bin/env bash
# Bootstrap a fresh macOS box from this dotfiles repo.
set -euo pipefail

DOTFILES="${DOTFILES:-$HOME/dotfiles/.config}"

echo "==> macOS bootstrap"

# 1. Homebrew
if ! command -v brew &>/dev/null; then
  echo "==> installing Homebrew"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Make brew available in this shell
if [[ -d /opt/homebrew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -d /usr/local/Homebrew ]]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi

# 2. Packages
echo "==> brew bundle"
brew bundle --file="$DOTFILES/homebrew/Brewfile"

# 3. Symlinks
echo "==> symlinking config"
bash "$DOTFILES/scripts/link.sh"

# 4. TPM (tmux plugin manager)
if [[ ! -d "$HOME/.tmux/plugins/tpm" ]]; then
  echo "==> installing TPM"
  git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
fi

# 5. nvm
if [[ ! -d "$HOME/.nvm" ]]; then
  echo "==> installing nvm"
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
fi

# 6. Default shell — zsh ships with macOS, just point at it
if [[ "$SHELL" != *zsh ]]; then
  echo "==> changing default shell to zsh"
  chsh -s "$(command -v zsh)"
fi

# 7. tmux + nvim plugins
bash "$DOTFILES/scripts/install-plugins.sh"

# 8. gh auth — interactive; needed before cloning private repos (tex)
bash "$DOTFILES/scripts/auth-github.sh"

# 9. tex repo (AI config: CLAUDE.md, skills, commands → ~/.claude/)
bash "$DOTFILES/scripts/setup-tex.sh"

echo "==> done. Open a new shell."
