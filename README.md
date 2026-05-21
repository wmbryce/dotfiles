# Dotfiles

Personal dotfiles. Works on macOS and Linux.

Focus: tmux + nvim + zsh, agentic dev workflow.

## Install (local machine)

```sh
git clone https://github.com/wmbryce/dotfiles ~/dotfiles
bash ~/dotfiles/.config/scripts/bootstrap.sh
```

`bootstrap.sh` detects the OS and runs `bootstrap-macos.sh` or `bootstrap-linux.sh`. Both:

- install packages (Homebrew on mac; apt/dnf/pacman on Linux)
- install starship, nvm, TPM, zplug
- symlink `~/.config/*` and `~/.zshrc` to this repo
- switch the default shell to zsh
- run `install-plugins.sh` (headless TPM + Lazy.nvim sync, Treesitter parsers, Mason registry)
- prompt for `gh auth login` (skipped if already authed) and run `gh auth setup-git` so private https clones work
- clone the [tex](https://github.com/wmbryce/tex) repo into `~/tex` and run `tex/install.sh` to wire its CLAUDE.md, skills, and slash commands into `~/.claude/`

Re-runnable any time. Just need the symlinks?

```sh
bash ~/dotfiles/.config/scripts/link.sh
```

Just need to (re)install tmux + nvim plugins?

```sh
bash ~/dotfiles/.config/scripts/install-plugins.sh
```

Just need to (re)set up the AI config repo?

```sh
bash ~/dotfiles/.config/scripts/setup-tex.sh
```

### Companion repo: `tex`

AI / Claude Code config (global `CLAUDE.md`, custom skills, slash commands, wiki) lives in a separate repo: <https://github.com/wmbryce/tex>. The dotfiles bootstrap clones it to `~/tex` and runs `~/tex/install.sh`, which symlinks:

- `~/tex/CLAUDE.md`  → `~/.claude/CLAUDE.md`
- `~/tex/commands/*.md` → `~/.claude/commands/`
- `~/tex/skills/*/`     → `~/.claude/skills/`

Two repos, one command. Keep dotfiles for shell/editor, keep tex for everything Claude reads. A `git pull` in `~/tex` is enough to roll out updates to global AI context on this machine.

## Layout

```
.config/
  scripts/
    bootstrap.sh           # OS-detecting entrypoint
    bootstrap-macos.sh     # brew bundle + link + plugins
    bootstrap-linux.sh     # apt/dnf/pacman + link + plugins
    link.sh                # symlink ~/.config and ~/.zshrc
    install-plugins.sh     # headless TPM install + nvim Lazy sync
    setup-tex.sh           # clone+install the tex AI-config repo
    auth-github.sh         # idempotent `gh auth login` + `gh auth setup-git`
    packages-linux.txt     # package list (apt names, mapped for dnf/pacman)
  homebrew/Brewfile        # mac package list
  zsh/zshrc                # cross-platform; detects brew prefix
  tmux/
    tmux.conf              # base config
    macos.conf             # mac clipboard (pbcopy)
    linux.conf             # linux clipboard (wl-copy / xclip), xdg-open
  nvim/                    # LazyVim setup
  git/, gh/, glab-cli/     # vcs tooling
  ...                      # mac-only GUI configs skipped on Linux
```

## Per-OS notes

**macOS** — Homebrew. Brewfile is source of truth; `brewup` alias keeps it dumped.

**Linux** — primary target Debian/Ubuntu (`bootstrap-linux.sh` also handles dnf and pacman with a small name remap). starship, zoxide, nvm, glab install via official curl scripts when missing.

---

## Setting up a fresh macOS machine

End-to-end recipe for a clean Mac. Should take ~30 min including downloads.

### 1. Apple basics

1. Sign in to iCloud and run **System Settings → General → Software Update** until clean.
2. Enable FileVault (System Settings → Privacy & Security).
3. Install **Xcode Command Line Tools** — needed for git/clang/Homebrew:
   ```sh
   xcode-select --install
   ```
   Wait for the GUI installer to finish before continuing.

### 2. Generate an SSH key + add to GitHub

```sh
ssh-keygen -t ed25519 -C "michael@steppingblocks.com"
pbcopy < ~/.ssh/id_ed25519.pub
```

Paste into GitHub → Settings → SSH and GPG keys → New SSH key.

Test:
```sh
ssh -T git@github.com
```

### 3. Clone dotfiles + bootstrap

```sh
git clone git@github.com:wmbryce/dotfiles.git ~/dotfiles
bash ~/dotfiles/.config/scripts/bootstrap.sh
exec zsh -l
```

That single command:
- installs Homebrew (if missing)
- runs `brew bundle` against `homebrew/Brewfile` (CLI tools + casks like ghostty, zed, clickhouse)
- symlinks everything in `.config/` plus `~/.zshrc`
- installs TPM, nvm
- changes the default shell to zsh
- runs headless plugin install for tmux + nvim
- prompts for `gh auth login` if you're not already authed (the only interactive step), then `gh auth setup-git`
- clones `tex` to `~/tex` and wires it into `~/.claude/`

### 4. Terminal of choice

The Brewfile installs **Ghostty**. Open it; the config in `~/.config/ghostty/` is already symlinked.

### 5. Window manager / OS tweaks (manual, GUI-only)

These aren't scripted because they're one-time GUI clicks:

- **Karabiner-Elements**: install from <https://karabiner-elements.pqrs.org/>. Config in `~/.config/karabiner/` is symlinked — open Karabiner once so it picks the file up.
- **Raycast**: install from the App Store / raycast.com. Settings sync via their cloud; the `~/.config/raycast/` dir mostly holds extensions.
- **iTerm2** (only if you prefer it over Ghostty): import `~/.config/iterm2/`.

Optional system defaults worth tweaking via Terminal:
```sh
defaults write NSGlobalDomain InitialKeyRepeat -int 15
defaults write NSGlobalDomain KeyRepeat -int 2
defaults write com.apple.dock autohide -bool true
killall Dock
```

### 6. Sign in to the other CLIs

`gh` is already authed (the bootstrap prompted for it). Do the others:

```sh
glab auth login         # gitlab
linear --help           # schpet/linear cli — runs token flow on first command
claude /login           # claude code
```

### 7. tmux + nvim sanity check

```sh
tmux new -s dev
# inside tmux:
`+I        # TPM plugin install (should be no-op since bootstrap already ran it)
nvim       # Lazy panel opens; confirm everything loaded
```

If you ever want to redo plugins only:
```sh
bash ~/.config/scripts/install-plugins.sh
```

### 8. Daily workflow

```sh
sup-work ~/code/some-project     # opens nvim + claude + shell tmux layout
```

### Quick checklist

- [ ] CLT installed
- [ ] ssh key generated, added to GitHub
- [ ] dotfiles cloned, `bootstrap.sh` finished
- [ ] Ghostty / Karabiner / Raycast launched once
- [ ] `gh`, `glab`, `linear`, `claude` signed in
- [ ] `tmux new -s dev` works end to end

---

## Setting up a fresh Linux VPS (Hetzner)

End-to-end recipe for a remote dev box. The same dotfiles run there.

### 1. Provision the server

1. Hetzner Console → **Add Server**.
2. Location: closest region to you (e.g. `ash` Ashburn for US east).
3. Image: **Ubuntu 24.04**.
4. Type: CX22 (€4/mo, 2 vCPU / 4 GB) is fine for one agent + a vim session; bump to CPX31 if you want headroom for builds.
5. **SSH keys**: paste your public key (`cat ~/.ssh/id_ed25519.pub`). Add one now — it skips the root-password emails.
6. Name the server, create.

Note the public IPv4. Set a DNS A record if you have a domain; not required.

### 2. First login + create your user

```sh
ssh root@<server-ip>

# create a non-root user with sudo
adduser mb
usermod -aG sudo mb

# copy your ssh key across
rsync --archive --chown=mb:mb ~/.ssh /home/mb
```

Log out. From now on you SSH as `mb`.

### 3. Lock down SSH

On the server, as `mb`:

```sh
sudo sed -i \
  -e 's/^#\?PermitRootLogin.*/PermitRootLogin no/' \
  -e 's/^#\?PasswordAuthentication.*/PasswordAuthentication no/' \
  -e 's/^#\?KbdInteractiveAuthentication.*/KbdInteractiveAuthentication no/' \
  /etc/ssh/sshd_config
sudo systemctl reload ssh
```

Test in a **new** terminal (`ssh mb@<server-ip>`) before closing your existing session.

### 4. Firewall

```sh
sudo apt-get update && sudo apt-get install -y ufw
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow OpenSSH
sudo ufw enable
```

If you'll run an HTTP service: `sudo ufw allow 80,443/tcp`.

### 5. Unattended security updates

```sh
sudo apt-get install -y unattended-upgrades
sudo dpkg-reconfigure -plow unattended-upgrades  # answer yes
```

### 6. Clone dotfiles + bootstrap

```sh
sudo apt-get install -y git
git clone https://github.com/wmbryce/dotfiles ~/dotfiles
bash ~/dotfiles/.config/scripts/bootstrap.sh
exec zsh -l
```

`bootstrap.sh` installs every package in `packages-linux.txt`, starship/zoxide/nvm/glab via curl, sets up zsh as the default shell, symlinks all configs, runs the headless plugin install for tmux + nvim, prompts for `gh auth login`, and clones `tex` into `~/tex` (wiring it into `~/.claude/`). Re-runnable any time.

> On a VPS, `gh auth login` → "Login with a web browser" gives you a code to paste into github.com/login/device — no key juggling, and `git clone` over https against private repos works immediately after.

### 7. Persistent tmux for remote work

When you reconnect over SSH, attach the same session:

```sh
tmux new -A -s dev   # creates dev if missing, attaches if it exists
```

Detach with `` `+d ``; everything keeps running. Pair with `sup-work` (alias to `~/.config/zsh/setup-workspace.sh`) for the nvim + agent + shell pane layout.

For drop-on/drop-off resilience (handles network changes, sleep, roaming):

```sh
sudo apt-get install -y mosh
sudo ufw allow 60000:61000/udp
# from your laptop:
mosh mb@<server-ip>
```

### 8. Remote development from your local editor (optional)

- **VS Code / Cursor**: install the *Remote - SSH* extension → "Connect to Host" → `mb@<server-ip>`.
- **JetBrains Gateway**: SSH to the same host, point at the project dir.
- **Pure tmux/nvim**: `ssh mb@<server-ip> -t "tmux new -A -s dev"`.

Add a `~/.ssh/config` entry on your laptop:

```
Host vps
  HostName <server-ip>
  User mb
  IdentityFile ~/.ssh/id_ed25519
  ServerAliveInterval 60
```

Then it's just `ssh vps` or `mosh vps`.

### 9. Long-running tasks / agents

For background jobs that survive disconnect, options ranked by complexity:

- **tmux session** — simplest. Start the process inside a named tmux window, detach.
- **systemd user unit** — for things that should auto-restart. Drop a unit in `~/.config/systemd/user/` and `loginctl enable-linger mb` so it runs without an active login.
- **Docker / Podman** — when you want isolated dependencies.

### 10. Backups

Hetzner offers automated snapshots (€/mo, configurable in the console). Worth turning on for any box you care about.

### Quick checklist

- [ ] server provisioned, SSH key uploaded
- [ ] non-root sudo user created, ssh key copied
- [ ] root + password ssh login disabled, tested new session
- [ ] ufw enabled, OpenSSH allowed
- [ ] unattended-upgrades on
- [ ] dotfiles cloned + `bootstrap.sh` run
- [ ] `~/.ssh/config` entry on laptop
- [ ] mosh (optional)
- [ ] linger enabled if running persistent user services

---

## Components

- **nvim** — LazyVim + Catppuccin. Plugins installed headlessly via `install-plugins.sh`.
- **tmux** — TPM + Catppuccin + vim-tmux-navigator. OSC52 clipboard set so copy works over SSH.
- **zsh** — vi mode, fzf, zoxide, starship, zplug (syntax-highlight / autosuggestions / completions). Homebrew prefix auto-detected (Apple Silicon, Intel mac, linuxbrew).

## Credits

- [craftzdog/dotfiles-public](https://github.com/craftzdog/dotfiles-public)
- [dreamsofcode-io/dotfiles](https://github.com/dreamsofcode-io/dotfiles)
