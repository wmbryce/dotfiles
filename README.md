# Personal Dotfiles

This repository contains my personal configuration files (dotfiles) for various tools and applications I use in my development environment.
These configurations are tailored to my workflow and preferences, primarily focusing on tmux, Neovim, and the fish shell.

## Overview

- **Neovim**: Configured with Lazy.nvim as the package manager and Catppuccin as the color scheme.
- **tmux**: Using TPM (Tmux Plugin Manager) for plugin management and Catppuccin for theming.
- **Fish Shell**: Utilizing Fisher for plugin management and a customized version of the Starship prompt.
- nvm: For managing Node.js versions
- pyenv: For managing Python versions

## Installation

- Clone the repository to your home directory

- Symlink the .config file to your home directory
  `ln -s ~/dotfiles/.config ~/.config`

- Install [Fish](https://fishshell.com/docs/current/install.html)
  `brew install fish`

- Install [Fisher](https://github.com/jorgebucaran/fisher)
  `curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install jorgebucaran/fisher`

- Install [Starship](https://starship.rs/)
  `brew install starship`

- Make fish your default shell
  `echo /usr/local/bin/fish | sudo tee -a /etc/shells`
  `chsh -s /usr/local/bin/fish`


- Install [Neovim](https://github.com/neovim/neovim/wiki/Installing-Neovim)
  `brew install neovim`

- Install [tmux](https://github.com/tmux/tmux/wiki)
  `brew install tmux`
  - Install [tpm](https://github.com/tmux-plugins/tpm)
  `brew install tpm`


- Install [nvm](https://github.com/nvm-sh/nvm) and [pyenv](https://github.com/pyenv/pyenv)
- Symlink the .config directory to your home directory
-`ln -s ./.config ~/.config`
-

## Components

### Neovim

My Neovim configuration uses Lazy.nvim for efficient plugin management. Key features include:

- Catppuccin color scheme for a pleasant coding experience
- Currently using supermaven for completions
- TS extension for TypeScript

### tmux

The tmux configuration includes:

- TPM for managing tmux plugins
- Catppuccin theme for visual consistency with Neovim

### Fish Shell

Fish shell is set up with:

- Fisher for plugin management
- A customized Starship prompt for an informative and attractive command line

## Acknowledgments

This configuration was greatly influenced by:

- [craftzdog's dotfiles](https://github.com/craftzdog/dotfiles-public)
- [Dreams of Code dotfiles](https://github.com/dreamsofcode-io/dotfiles)

## Personal Notes

*[You can add any personal notes, TODO items, or future plans for your dotfiles here]*

