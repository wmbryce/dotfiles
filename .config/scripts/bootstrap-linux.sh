#!/usr/bin/env bash
# Bootstrap a fresh Linux box (Debian/Ubuntu primary; basic dnf/pacman support).
set -euo pipefail

DOTFILES="${DOTFILES:-$HOME/dotfiles/.config}"

echo "==> Linux bootstrap"

# -- detect package manager ---------------------------------------------------
PKG=""
SUDO=""
[[ "$EUID" -ne 0 ]] && command -v sudo &>/dev/null && SUDO="sudo"

if   command -v apt-get &>/dev/null; then PKG="apt"
elif command -v dnf     &>/dev/null; then PKG="dnf"
elif command -v pacman  &>/dev/null; then PKG="pacman"
else
  echo "!! no known package manager (apt/dnf/pacman). Install packages manually then re-run with SKIP_PKG=1."
  [[ "${SKIP_PKG:-}" != "1" ]] && exit 1
fi
echo "==> package manager: ${PKG:-skipped}"

# -- distro-name remapping for a few packages --------------------------------
# Anything not listed here is passed through unchanged.
map_pkg() {
  local p="$1"
  case "$PKG:$p" in
    dnf:build-essential)    echo "@development-tools" ;;
    pacman:build-essential) echo "base-devel" ;;
    dnf:fd-find)            echo "fd-find" ;;
    pacman:fd-find)         echo "fd" ;;
    pacman:ripgrep)         echo "ripgrep" ;;
    dnf:python3-venv)       echo "python3-virtualenv" ;;
    pacman:python3-pip)     echo "python-pip" ;;
    pacman:python3-venv)    echo "" ;;  # included in python on arch
    pacman:python3)         echo "python" ;;
    pacman:golang-go)       echo "go" ;;
    dnf:golang-go)          echo "golang" ;;
    pacman:wl-clipboard)    echo "wl-clipboard" ;;
    pacman:git-delta)       echo "git-delta" ;;
    dnf:git-delta)          echo "git-delta" ;;
    *) echo "$p" ;;
  esac
}

# -- add github cli apt repo (apt-only; idempotent) ---------------------------
# Ubuntu 22.04+ has gh in universe, but Debian doesn't ship it. Add the
# official repo unconditionally on apt systems so the package install below
# always succeeds.
if [[ "$PKG" == "apt" && ! -f /etc/apt/sources.list.d/github-cli.list ]]; then
  echo "==> adding github cli apt source"
  $SUDO apt-get install -y curl gpg ca-certificates
  curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
    | $SUDO dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
  $SUDO chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
    | $SUDO tee /etc/apt/sources.list.d/github-cli.list >/dev/null
fi

# -- install packages ---------------------------------------------------------
if [[ "${SKIP_PKG:-}" != "1" ]]; then
  pkgs=()
  while IFS= read -r line; do
    line="${line%%#*}"
    line="$(echo "$line" | xargs)"
    [[ -z "$line" ]] && continue
    mapped="$(map_pkg "$line")"
    [[ -n "$mapped" ]] && pkgs+=("$mapped")
  done < "$DOTFILES/scripts/packages-linux.txt"

  case "$PKG" in
    apt)
      $SUDO apt-get update
      $SUDO DEBIAN_FRONTEND=noninteractive apt-get install -y "${pkgs[@]}"
      ;;
    dnf)
      $SUDO dnf install -y "${pkgs[@]}"
      ;;
    pacman)
      $SUDO pacman -Syu --needed --noconfirm "${pkgs[@]}"
      ;;
  esac
fi

# -- starship (curl installer; not packaged everywhere) ----------------------
if ! command -v starship &>/dev/null; then
  echo "==> installing starship"
  curl -sS https://starship.rs/install.sh | sh -s -- -y
fi

# -- zoxide fallback (if not packaged) ---------------------------------------
if ! command -v zoxide &>/dev/null; then
  echo "==> installing zoxide"
  curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
fi

# -- nvm ----------------------------------------------------------------------
if [[ ! -d "$HOME/.nvm" ]]; then
  echo "==> installing nvm"
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
fi

# -- zplug --------------------------------------------------------------------
if [[ ! -d "$HOME/.zplug" ]]; then
  echo "==> installing zplug"
  git clone https://github.com/zplug/zplug "$HOME/.zplug"
fi

# -- glab (gitlab cli) -------------------------------------------------------
if ! command -v glab &>/dev/null; then
  echo "==> installing glab"
  case "$PKG" in
    apt)
      curl -fsSL https://gitlab.com/gitlab-org/cli/-/raw/main/scripts/install.sh | $SUDO bash
      ;;
    *)
      echo "   skipped (install glab manually for $PKG)"
      ;;
  esac
fi

# -- fd symlink: Debian ships /usr/bin/fdfind ---------------------------------
if command -v fdfind &>/dev/null && ! command -v fd &>/dev/null; then
  mkdir -p "$HOME/.local/bin"
  ln -sf "$(command -v fdfind)" "$HOME/.local/bin/fd"
fi

# -- TPM (tmux plugin manager) -----------------------------------------------
if [[ ! -d "$HOME/.tmux/plugins/tpm" ]]; then
  echo "==> installing TPM"
  git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
fi

# -- symlink configs ----------------------------------------------------------
echo "==> symlinking config"
bash "$DOTFILES/scripts/link.sh"

# -- default shell ------------------------------------------------------------
if command -v zsh &>/dev/null && [[ "$SHELL" != *zsh ]]; then
  zsh_path="$(command -v zsh)"
  grep -q "^$zsh_path\$" /etc/shells || echo "$zsh_path" | $SUDO tee -a /etc/shells >/dev/null
  echo "==> changing default shell to $zsh_path"
  chsh -s "$zsh_path" || echo "   (chsh failed — set manually with: chsh -s $zsh_path)"
fi

# -- tmux + nvim plugins ------------------------------------------------------
bash "$DOTFILES/scripts/install-plugins.sh"

# -- gh auth ------------------------------------------------------------------
# Interactive; needed before cloning private repos (tex).
bash "$DOTFILES/scripts/auth-github.sh"

# -- tex repo (AI config) -----------------------------------------------------
bash "$DOTFILES/scripts/setup-tex.sh"

echo "==> done. Open a new shell."
