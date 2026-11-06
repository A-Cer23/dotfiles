#!/usr/bin/env bash
# Bootstrap Ghostty + Zellij + LazyVim on macOS or Ubuntu (incl. WSL).
#   curl -fsSL https://raw.githubusercontent.com/A-Cer23/dotfiles/main/install.sh | bash
# Nothing is cloned: configs are downloaded to a temp dir and copied into ~/.config.
# Safe to re-run: installs anything missing and refreshes configs (old ones are backed up).
set -euo pipefail

TARBALL="https://github.com/A-Cer23/dotfiles/archive/refs/heads/main.tar.gz"

# Packages (Homebrew on macOS and Linux). Ghostty: cask on macOS, apt on Linux.
BREW_PACKAGES=(
  neovim zellij              # editor + terminal workspace
  git lazygit gh             # git & GitHub
  ripgrep fd tree-sitter-cli # LazyVim: search, file picker, Treesitter parsers
  node                       # TypeScript language server
)

export HOMEBREW_NO_ENV_HINTS=1

log() { printf '\n\033[1;34m==> %s\033[0m\n' "$*"; }

# Everything runs inside main() so bash reads the whole script before running it.
# Without that, `curl | bash` lets commands like nvim/apt eat the rest of the script from stdin.
main() {
  local os is_wsl=false rc
  os="$(uname -s)"
  grep -qi microsoft /proc/version 2>/dev/null && is_wsl=true

  if [[ "$os" == "Linux" ]]; then
    log "Installing apt prerequisites"
    sudo apt-get update
    sudo apt-get install -y -o Dpkg::Progress-Fancy=1 build-essential procps curl file git unzip
    rc="$HOME/.bashrc"
  else
    rc="$HOME/.zshrc"   # Homebrew's installer handles Xcode CLT on macOS
  fi

  if ! command -v brew >/dev/null; then
    log "Installing Homebrew"
    NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi
  local b
  for b in /opt/homebrew/bin/brew /usr/local/bin/brew /home/linuxbrew/.linuxbrew/bin/brew; do
    [[ -x "$b" ]] && eval "$("$b" shellenv)" && break
  done

  # brew install (unlike brew bundle) prints each download with a progress bar
  log "Installing packages: ${BREW_PACKAGES[*]}"
  brew install "${BREW_PACKAGES[@]}"

  if [[ "$os" == "Darwin" ]]; then
    log "Installing Ghostty"
    brew install --cask ghostty
  elif ! command -v ghostty >/dev/null; then
    # Ubuntu 26.04+ ships it in apt. On WSL it runs through WSLg.
    log "Installing Ghostty"
    if apt-cache show ghostty >/dev/null 2>&1; then
      sudo apt-get install -y -o Dpkg::Progress-Fancy=1 ghostty
    else
      # Older Ubuntu: community .deb, https://github.com/mkasberg/ghostty-ubuntu
      /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/mkasberg/ghostty-ubuntu/HEAD/install.sh)"
    fi
  fi

  log "Downloading configs"
  tmp="$(mktemp -d)"   # global so the EXIT trap can still see it
  trap 'rm -rf "$tmp"' EXIT
  curl -fL --progress-bar "$TARBALL" | tar -xz -C "$tmp" --strip-components=1

  log "Installing configs into ~/.config"
  mkdir -p "$HOME/.config"
  local app target
  for app in nvim zellij ghostty shell; do
    target="$HOME/.config/$app"
    # Back up anything that differs from the repo (or is a symlink from an old install)
    if [[ -L "$target" ]]; then
      rm "$target"
    elif [[ -e "$target" ]] && ! diff -rq -x lazy-lock.json "$tmp/config/$app" "$target" >/dev/null 2>&1; then
      mv "$target" "$target.bak.$(date +%s)"
      echo "  backed up old $target"
    fi
    mkdir -p "$target"
    cp -R "$tmp/config/$app/." "$target/"
  done

  # One line in the shell rc; the rest lives in ~/.config/shell/rc.sh
  local src_line='source "$HOME/.config/shell/rc.sh"'
  touch "$rc"
  grep -qxF "$src_line" "$rc" || printf '\n%s\n' "$src_line" >> "$rc"

  log "Installing LazyVim plugins (can take a minute)"
  nvim --headless "+Lazy! sync" +qa </dev/null || true

  log "Done. Next steps:"
  echo "  1. Restart your shell (or: source $rc)"
  echo "  2. gh auth login"
  if $is_wsl; then
    echo "  3. Start menu -> 'Ghostty (Ubuntu)' (or run: ghostty &), then: zellij"
  else
    echo "  3. Open Ghostty, then: zellij"
  fi
}

main "$@"
