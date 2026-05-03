# Dotfiles

This repository stores the current `Neovim` and `tmux` configuration under Windows11.

## Structure

- `nvim/`
  Current Neovim config copied from `C:\Users\A\AppData\Local\nvim`
- `tmux/tmux.conf`
  Current tmux config
- `nvim_keys.txt`
  Practical Neovim key usage notes
- `tmux_keys.txt`
  Practical tmux key usage notes

## Current install locations

- Neovim config path on Windows:
  `C:\Users\A\AppData\Local\nvim`
- tmux config in this workspace:
  `C:\Users\A\cpp\tmux.conf`

## Restore these configs on this machine

### Neovim

Copy the repo `nvim` directory to:

`C:\Users\A\AppData\Local\nvim`

### tmux

Copy:

`tmux\tmux.conf`

to the place where you keep your active `tmux.conf`.

## GitHub push steps

This machine does not currently have `gh` installed, so the repo is prepared locally only.

After you create an empty GitHub repo, run:

```powershell
cd C:\Users\A\cpp\dotfiles
git add .
git commit -m "Initial dotfiles import"
git branch -M main
git remote add origin <your-github-repo-url>
git push -u origin main
```

## Notes

- The Neovim config includes the current `tokyonight` theme setup.
- The Neovim config includes current `clangd`, `pyright`, completion, and `F5`/`F6`/`F7` workflow settings.
