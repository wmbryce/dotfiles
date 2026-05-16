# Personal Dotfiles

My personal configuration for a terminal-first development environment built around **zsh + tmux + Neovim**, tuned for agentic dev workflows (Claude Code, multi-pane sessions, fast shell startup).

## Overview

| Tool | Role |
| --- | --- |
| **zsh** | Primary shell, with lazy-loaded `nvm` for fast startup |
| **Starship** | Cross-shell prompt |
| **tmux** | Terminal multiplexer, TPM-managed plugins, Catppuccin theme |
| **Neovim** | Editor, built on [LazyVim](https://www.lazyvim.org/) |
| **Ghostty** | Primary terminal emulator (iTerm2 config kept as fallback) |
| **Zed** | GUI editor for when Neovim isn't the right tool |
| **Raycast** | Launcher (settings only — extensions are gitignored) |
| **Karabiner** | Keyboard remapping on macOS |
| **gh / glab** | GitHub & GitLab CLIs |

`fish`, `doom.d`, `emacs`, `himalaya`, `yarn`, and a few others remain in `.config/` as leftovers or occasional tools but aren't part of the active daily setup.

## Installation

Clone into `~/dotfiles`, then run the setup script:

```sh
git clone <this-repo> ~/dotfiles
cd ~/dotfiles/.config
./setup.sh
```

`setup.sh` symlinks every directory under `.config/` into `~/.config/`, links `zsh/zshrc` → `~/.zshrc`, and links `tmux/plugins` → `~/.tmux/plugins`. Existing files at those paths are replaced.

### Dependencies

```sh
brew install zsh starship tmux neovim gh glab ghostty
```

- Make zsh your default shell: `chsh -s /opt/homebrew/bin/zsh`
- Install [TPM](https://github.com/tmux-plugins/tpm) (the `tmux/plugins` symlink expects it on disk)
- Install [nvm](https://github.com/nvm-sh/nvm) for Node version management
- First Neovim launch will trigger LazyVim to install plugins
- Inside tmux, run `prefix + I` to install plugins via TPM

## Components

### Neovim (`nvim/`)
LazyVim distribution with project-local customisations under `lua/`. `lazy-lock.json` pins plugin versions for reproducible setups.

### tmux (`tmux/`)
`tmux.conf` plus a `macos.conf` overlay. Plugins managed by TPM; theme is Catppuccin to match Neovim. Layout/keybinds are tuned for running Claude Code and dev servers side-by-side.

### zsh (`zsh/zshrc`)
- Auto-attaches to a `default` tmux session on interactive login (skipped inside VS Code)
- Lazy-loaded `nvm` — resolves the default Node version up front so `node`/`npm` work without paying nvm's full init cost
- Standard git/ls aliases, large shared history, vi keytimeout tweaks
- Starship prompt sourced from `.config/starship.toml`

### Ghostty (`ghostty/`)
Primary terminal emulator config + custom themes.

### Zed (`zed/`)
`settings.json`, `keymap.json`, custom prompts and themes.

### Git / GitHub / GitLab
- `git/` — global gitconfig
- `gh/` — GitHub CLI config and hosts
- `glab-cli/` — GitLab CLI config and aliases

### Raycast (`raycast/`)
Raycast settings and AI config. The `extensions/` subdirectory is gitignored — those binaries are managed by Raycast itself.

### Karabiner (`karabiner/`)
Keyboard remapping rules. Automatic backups are gitignored.

## Acknowledgments

Originally influenced by:
- [craftzdog's dotfiles](https://github.com/craftzdog/dotfiles-public)
- [Dreams of Code dotfiles](https://github.com/dreamsofcode-io/dotfiles)
