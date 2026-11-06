# Shared shell setup, sourced from ~/.bashrc (Linux/WSL) or ~/.zshrc (macOS).
# Edit here and commit; every machine picks it up.

for b in /opt/homebrew/bin/brew /usr/local/bin/brew /home/linuxbrew/.linuxbrew/bin/brew; do
  [ -x "$b" ] && eval "$("$b" shellenv)" && break
done
unset b

export EDITOR=nvim
export VISUAL=nvim

alias v=nvim
alias lg=lazygit
