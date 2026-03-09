#!/bin/bash

DOTFILES="$HOME/dotfiles/.config"
CONFIG="$HOME/.config"

mkdir -p "$CONFIG"
mkdir -p "$HOME/.tmux"

# symlink .config dirs/files
for item in "$DOTFILES"/*; do
  name=$(basename "$item")
  [[ "$name" == "setup.sh" ]] && continue

  target="$CONFIG/$name"
  [[ -e "$target" || -L "$target" ]] && rm -rf "$target"
  ln -s "$item" "$target"
  echo "linked $name"
done

# zshrc
[[ -e "$HOME/.zshrc" || -L "$HOME/.zshrc" ]] && rm -f "$HOME/.zshrc"
ln -s "$DOTFILES/zsh/zshrc" "$HOME/.zshrc"
echo "linked zshrc"

# tmux plugins
[[ -e "$HOME/.tmux/plugins" || -L "$HOME/.tmux/plugins" ]] && rm -rf "$HOME/.tmux/plugins"
ln -s "$CONFIG/tmux/plugins" "$HOME/.tmux/plugins"
echo "linked tmux plugins"

echo "done"
