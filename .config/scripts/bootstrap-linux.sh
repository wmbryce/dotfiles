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
      $SUDO env DEBIAN_FRONTEND=noninteractive apt-get install -y "${pkgs[@]}"
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
# Optional tool; never let a failure here abort the bootstrap. glab is packaged
# in apt (Ubuntu 24.04+), dnf and pacman; fall back to the GitHub release tarball
# everywhere else.
if ! command -v glab &>/dev/null; then
  echo "==> installing glab"
  install_glab() {
    case "$PKG" in
      apt)    $SUDO apt-get install -y glab && return 0 ;;
      dnf)    $SUDO dnf install -y glab && return 0 ;;
      pacman) $SUDO pacman -S --needed --noconfirm glab && return 0 ;;
    esac
    # Fallback: download the latest release tarball from gitlab.com.
    local arch ver tmp
    case "$(uname -m)" in
      x86_64)  arch="x86_64" ;;
      aarch64) arch="arm64" ;;
      *) echo "   no glab build for $(uname -m); skipping"; return 1 ;;
    esac
    ver="$(curl -fsSL 'https://gitlab.com/api/v4/projects/gitlab-org%2Fcli/releases/permalink/latest' 2>/dev/null \
            | grep -oP '"tag_name":"v?\K[^"]+' | head -1)"
    [[ -z "$ver" ]] && { echo "   could not resolve latest glab version; skipping"; return 1; }
    tmp="$(mktemp -d)"
    if curl -fsSL "https://gitlab.com/gitlab-org/cli/-/releases/v${ver}/downloads/glab_${ver}_linux_${arch}.tar.gz" \
         -o "$tmp/glab.tar.gz" && tar -xzf "$tmp/glab.tar.gz" -C "$tmp"; then
      mkdir -p "$HOME/.local/bin"
      install -m 0755 "$(find "$tmp" -name glab -type f | head -1)" "$HOME/.local/bin/glab"
      rm -rf "$tmp"; return 0
    fi
    rm -rf "$tmp"; return 1
  }
  install_glab || echo "   glab install failed; install it manually later (non-fatal)."
fi

# -- fd symlink: Debian ships /usr/bin/fdfind ---------------------------------
if command -v fdfind &>/dev/null && ! command -v fd &>/dev/null; then
  mkdir -p "$HOME/.local/bin"
  ln -sf "$(command -v fdfind)" "$HOME/.local/bin/fd"
fi

# -- symlink configs ----------------------------------------------------------
# Note: TPM is cloned by install-plugins.sh *after* this — link.sh resets
# ~/.tmux/plugins, so cloning TPM before linking would just be wiped.
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
# Interactive; needed before cloning private repos (tex). Non-fatal and
# skippable so an unattended VPS bootstrap still completes (set SKIP_AUTH=1).
if [[ "${SKIP_AUTH:-}" == "1" ]]; then
  echo "==> skipping gh auth (SKIP_AUTH=1)"
else
  bash "$DOTFILES/scripts/auth-github.sh" || echo "   gh auth skipped/failed (non-fatal)."
fi

# -- tex repo (AI config) -----------------------------------------------------
# Needs gh auth for the private clone; non-fatal and skippable (SKIP_TEX=1).
if [[ "${SKIP_TEX:-}" == "1" ]]; then
  echo "==> skipping tex setup (SKIP_TEX=1)"
else
  bash "$DOTFILES/scripts/setup-tex.sh" || echo "   tex setup skipped/failed (non-fatal)."
fi

echo "==> done. Open a new shell."
