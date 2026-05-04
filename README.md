# Windows tmux + Neovim Dotfiles
This repository stores the current Windows-focused `Neovim` and `tmux` configuration.

This is not a generic Linux dotfiles repo. Some behavior is intentionally Windows-specific, especially:

- `Neovim` lives under `C:\Users\A\AppData\Local\nvim`
- C/C++ build commands use Windows paths and PowerShell
- `tmux` copy mode sends text to the Windows clipboard through `clip.exe`
- `Windows Terminal` uses a Nerd Font configuration for terminal-side icons and statusline glyphs

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
- `windows_terminal.settings.json`
  Snapshot of the current Windows Terminal settings used with this setup
- `nvim_keys.txt`
  Practical Neovim key notes for this setup
- `nvim_tree_keys.txt`
  Practical project list and file tree operations for `nvim-tree`
- `neovide_keys.txt`
  Practical Neovide operations for common split, terminal, save, and build tasks
- `vim_motions_and_deletes.txt`
  Basic built-in Vim movement and delete operations for Neovim use
- `vim_search_replace_copy_paste_undo.txt`
  Basic built-in Vim search, replace, copy, paste, undo, and redo operations
- `tmux_keys.txt`
  Practical tmux key notes for this setup
- `WINDOWS_NOTES.md`
  Windows-specific notes for the Neovim setup
- `CLANGD_NOTES.md`
  Project-level `clangd` notes, including how to disable unused include warnings

## Restore these configs on Windows

### Neovim

Copy the repo `nvim` directory to:

`C:\Users\A\AppData\Local\nvim`

### tmux

Copy:

`tmux\tmux.conf`

to the place where you keep your active `tmux.conf`.

### Windows Terminal

If you want the same terminal-side rendering and font behavior, copy:

`windows_terminal.settings.json`

to:

`C:\Users\A\AppData\Local\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json`


## Notes

- The Neovim config includes the current `tokyonight` theme setup.
- The Neovim config includes current `clangd`, `pyright`, completion, and `F5`/`F6`/`F7`/`F8` workflow settings.
- In this setup, `:terminal` / `:term` are redirected to open from the current file directory by default.
- The repo includes the current Windows Terminal font/rendering settings snapshot.
- The repo also includes a note for project-local `.clangd` settings such as disabling unused include warnings.
- The tmux config uses `Ctrl+w` as prefix instead of the default `Ctrl+b`.
