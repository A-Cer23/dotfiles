#!/usr/bin/env bash
# Bootstrap: Ghostty + Zellij + LazyVim on macOS or Ubuntu (incl. WSL).
# Usage on a fresh machine:
#   curl -fsSL https://raw.githubusercontent.com/<you>/dotfiles/main/install.sh | bash
set -euo pipefail

REPO="https://github.com/A-Cer23/dotfiles.git"   # <-- change this
DOTFILES="$HOME/dotfiles"

log() { printf '\n\033[1;34m==> %s\033[0m\n' "$*"; }

OS="$(uname -s)"
IS_WSL=false
grep -qi microsoft /proc/version 2>/dev/null && IS_WSL=true

# 1. System prerequisites (Linux only; Homebrew's installer handles Xcode CLT on macOS)
if [[ "$OS" == "Linux" ]]; then
  log "Installing apt prerequisites"
  sudo apt-get update -y
  sudo apt-get install -y build-essential procps curl file git unzip
fi

# 2. Homebrew
if ! command -v brew >/dev/null; then
  log "Installing Homebrew"
  NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
if [[ "$OS" == "Darwin" ]]; then
  BREW_BIN=/opt/homebrew/bin/brew
  [[ -x "$BREW_BIN" ]] || BREW_BIN=/usr/local/bin/brew   # Intel Macs
  RC="$HOME/.zshrc"
else
  BREW_BIN=/home/linuxbrew/.linuxbrew/bin/brew
  RC="$HOME/.bashrc"
fi
eval "$("$BREW_BIN" shellenv)"
BREW_ENV="eval \"\$($BREW_BIN shellenv)\""

# 3. Clone or update this repo
if [[ -d "$DOTFILES/.git" ]]; then
  log "Updating dotfiles"
  git -C "$DOTFILES" pull --ff-only
else
  log "Cloning dotfiles"
  git clone "$REPO" "$DOTFILES"
fi

# 4. CLI tools (+ Ghostty cask on macOS)
log "Installing packages from Brewfile"
brew bundle --file="$DOTFILES/Brewfile"

# 5. Ghostty on Ubuntu/WSL (runs through WSLg on Windows)
if [[ "$OS" == "Linux" ]] && ! command -v ghostty >/dev/null; then
  log "Installing Ghostty"
  if apt-cache show ghostty >/dev/null 2>&1; then
    sudo apt-get install -y ghostty                       # Ubuntu 26.04+
  else
    # Community .deb for older Ubuntu: https://github.com/mkasberg/ghostty-ubuntu
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/mkasberg/ghostty-ubuntu/HEAD/install.sh)"
  fi
fi

# 6. Link configs into ~/.config (existing ones are backed up once)
log "Linking configs"
mkdir -p "$HOME/.config"
for app in nvim zellij ghostty; do
  target="$HOME/.config/$app"
  if [[ -e "$target" && ! -L "$target" ]]; then
    mv "$target" "$target.bak.$(date +%s)"
  fi
  ln -sfn "$DOTFILES/config/$app" "$target"
done

# 7. Shell setup (idempotent)
touch "$RC"
grep -qxF "$BREW_ENV" "$RC" || echo "$BREW_ENV" >> "$RC"
grep -qxF 'export EDITOR=nvim' "$RC" || echo 'export EDITOR=nvim' >> "$RC"

# 8. Pre-install Neovim plugins
log "Installing LazyVim plugins"
nvim --headless "+Lazy! sync" +qa || true

log "Done. Next steps:"
echo "  1. Restart your shell (or: source $RC)"
echo "  2. gh auth login"
if $IS_WSL; then
  echo "  3. Launch Ghostty from the Start menu ('Ghostty (Ubuntu)') or run: ghostty &"
else
  echo "  3. Open Ghostty, run: zellij"
fi
