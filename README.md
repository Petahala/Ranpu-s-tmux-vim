# Windows tmux + Neovim Dotfiles
This repository stores the current Windows-focused `Neovim` and `tmux` configuration used on this machine.

This is not a generic Linux dotfiles repo. Some behavior is intentionally Windows-specific, especially:

- `Neovim` lives under `C:\Users\A\AppData\Local\nvim`
- C/C++ build commands use Windows paths and PowerShell
- `tmux` copy mode sends text to the Windows clipboard through `clip.exe`

## Current install locations

- Neovim config path on Windows:
  `C:\Users\A\AppData\Local\nvim`
- tmux config in this workspace:
  `C:\Users\A\cpp\tmux.conf`

## Repository contents

- `nvim/`
  Active Neovim config copied from the Windows Neovim config directory
- `tmux/tmux.conf`
  Current tmux config
- `nvim_keys.txt`
  Practical Neovim key notes for this setup
- `tmux_keys.txt`
  Practical tmux key notes for this setup

## Restore these configs on Windows

### Neovim

Copy the repo `nvim` directory to:

`C:\Users\A\AppData\Local\nvim`

### tmux

Copy:

`tmux\tmux.conf`

to the place where you keep your active `tmux.conf`.

## Update and push

This repository is already connected to GitHub. To update it later, run:

```powershell
cd C:\Users\A\cpp\dotfiles
git add .
git commit -m "update configs"
git push
```

## Notes

- The Neovim config includes the current `tokyonight` theme setup.
- The Neovim config includes current `clangd`, `pyright`, completion, and `F5`/`F6`/`F7` workflow settings.
- The tmux config uses `Ctrl+w` as prefix instead of the default `Ctrl+b`.
