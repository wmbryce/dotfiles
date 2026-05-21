#!/usr/bin/env bash
# Symlink ~/.config items from this repo. OS-aware: skips mac-only items on Linux.
set -euo pipefail

DOTFILES="${DOTFILES:-$HOME/dotfiles/.config}"
CONFIG="${CONFIG:-$HOME/.config}"
OS="$(uname -s)"

# Items that are mac-only (configs for GUI apps that don't exist on Linux).
# We just skip them on Linux — symlinking is harmless but pointless.
MAC_ONLY=(karabiner raycast iterm2 ghostty homebrew zed fish)

is_mac_only() {
  local name="$1"
  for m in "${MAC_ONLY[@]}"; do
    [[ "$name" == "$m" ]] && return 0
  done
  return 1
}

mkdir -p "$CONFIG" "$HOME/.tmux"

for item in "$DOTFILES"/*; do
  name="$(basename "$item")"
  case "$name" in
    setup.sh|scripts) continue ;;
  esac

  if [[ "$OS" != "Darwin" ]] && is_mac_only "$name"; then
    echo "skip (mac-only) $name"
    continue
  fi

  target="$CONFIG/$name"
  [[ -e "$target" || -L "$target" ]] && rm -rf "$target"
  ln -s "$item" "$target"
  echo "linked $name"
done

# zshrc
[[ -e "$HOME/.zshrc" || -L "$HOME/.zshrc" ]] && rm -f "$HOME/.zshrc"
ln -s "$DOTFILES/zsh/zshrc" "$HOME/.zshrc"
echo "linked zshrc"

# tmux plugins dir — TPM clones into ~/.tmux/plugins; symlink to .config/tmux/plugins
[[ -e "$HOME/.tmux/plugins" || -L "$HOME/.tmux/plugins" ]] && rm -rf "$HOME/.tmux/plugins"
mkdir -p "$CONFIG/tmux/plugins"
ln -s "$CONFIG/tmux/plugins" "$HOME/.tmux/plugins"
echo "linked tmux plugins"

echo "done"
