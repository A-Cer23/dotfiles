# dotfiles

Terminal-only dev setup: **Ghostty + Zellij + LazyVim**, on macOS or Ubuntu (incl. WSL on Windows).

## Install on a new machine

```bash
curl -fsSL https://raw.githubusercontent.com/A-Cer23/dotfiles/main/install.sh | bash
```

Then restart your shell and run `gh auth login`.

Nothing is cloned: the script downloads the configs to a temp folder, copies them into `~/.config`, and deletes the temp folder. Each install and download shows its progress.

Re-running the script is safe: it installs anything missing and refreshes the configs. Any config you changed locally is backed up to `~/.config/<app>.bak.<timestamp>` first.

### Windows (WSL)

1. In PowerShell: `wsl --install -d Ubuntu`, then `wsl --update`. Reboot if asked.
2. Open Ubuntu, create your user, and run the install command above.
3. Launch **Ghostty (Ubuntu)** from the Start menu (it runs through WSLg) and type `zellij`.
   Pin it to the taskbar so one click gets you working.

### macOS

Run the install command in Terminal.app. It installs Homebrew (plus the Xcode command line tools), then the Ghostty app. Open Ghostty and type `zellij`.

## What gets installed

| Tool | Purpose |
|---|---|
| Ghostty | Terminal (Homebrew cask on macOS, apt on Ubuntu/WSL) |
| Zellij | Persistent sessions, tabs, panes |
| Neovim + LazyVim | Editor, LSP, completion, syntax highlighting |
| lazygit | Git UI (`Space g g` in Neovim, or `lg`) |
| gh | GitHub CLI |
| ripgrep, fd | Search and file picking for LazyVim |
| tree-sitter-cli | Builds syntax parsers for LazyVim |
| node | TypeScript language server |

Everything except Ghostty on Linux comes from Homebrew, so versions match across machines. The package list is `BREW_PACKAGES` at the top of `install.sh`.

## Layout

```
install.sh            bootstrap script + package list
config/ghostty/       -> ~/.config/ghostty
config/zellij/        -> ~/.config/zellij
config/nvim/          -> ~/.config/nvim
config/shell/rc.sh    -> ~/.config/shell/rc.sh, sourced from ~/.bashrc (Linux) or ~/.zshrc (macOS)
```

Configs are copies, not links. To change one for every machine, edit it in this repo, push, and re-run the install command.
To pin plugin versions, copy `~/.config/nvim/lazy-lock.json` into `config/nvim/` and commit it.

## Daily keys

- **Zellij** starts locked so keys go to Neovim. `Ctrl+g` unlocks it; its shortcuts show in the bottom bar. `zellij attach` brings back a session after closing the window.
- **LazyVim**: `Space` shows all keymaps. `Space Space` find files, `Space /` grep, `Space g g` lazygit, `:LazyExtras` add language support.
- **Aliases**: `v` = nvim, `lg` = lazygit.
