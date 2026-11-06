# dotfiles

Terminal-only dev setup: **Ghostty + Zellij + LazyVim**, on macOS or Ubuntu (incl. WSL on Windows).

## Install on a new machine

```bash
curl -fsSL https://raw.githubusercontent.com/<you>/dotfiles/main/install.sh | bash
```

Then restart your shell and run `gh auth login`.

Re-running the script is safe: it pulls the repo, installs anything missing and relinks configs.

### Windows (WSL)

1. In PowerShell: `wsl --install -d Ubuntu`, then `wsl --update`.
2. Open Ubuntu and run the install command above.
3. Launch **Ghostty (Ubuntu)** from the Start menu. It runs through WSLg.

## What gets installed

| Tool | Purpose |
|---|---|
| Ghostty | Terminal |
| Zellij | Persistent sessions, tabs, panes |
| Neovim + LazyVim | Editor, LSP, completion, syntax highlighting |
| lazygit | Git UI (`Space g g` in Neovim) |
| gh | GitHub CLI |
| ripgrep, fd | Search and file picking for LazyVim |
| node | TypeScript language server |

## Layout

```
install.sh            bootstrap script
Brewfile              packages (Homebrew on macOS and Linux)
config/ghostty/       -> ~/.config/ghostty
config/zellij/        -> ~/.config/zellij
config/nvim/          -> ~/.config/nvim
```

Configs are symlinked, so editing `~/.config/nvim` edits the repo. Commit and push to sync.
After the first Neovim launch, commit `config/nvim/lazy-lock.json` to pin plugin versions.

## Daily keys

- **Zellij** starts locked so keys go to Neovim. `Ctrl+g` unlocks it; its shortcuts show in the bottom bar.
- **LazyVim**: `Space` shows all keymaps. `Space Space` find files, `Space /` grep, `Space g g` lazygit, `:LazyExtras` add language support.
