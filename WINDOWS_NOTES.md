# Windows Notes

This file documents the Windows-specific assumptions in this `Neovim` setup.

## Config path

The active Neovim config on this machine is expected at:

`C:\Users\A\AppData\Local\nvim`

This repository mirrors that config under:

`nvim/`

## Shell assumptions

Several workflow functions in `nvim/lua/conf/keymap.lua` explicitly use:

- `powershell`
- `-NoLogo`
- `-NoProfile`
- `-Command`

This affects:

- `F5` single-file C/C++ compile
- `F6` running the current file's matching `.exe`
- `F7` building the CMake project
- `F8` refreshing `build-clangd/compile_commands.json`

These commands are currently written for Windows PowerShell syntax, including:

- `Write-Host`
- `Read-Host`
- `$LASTEXITCODE`

## Compiler paths

The current config hardcodes Windows compiler paths in `nvim/lua/conf/keymap.lua`:

- `D:\programs\mingw\bin\g++.exe`
- `D:\programs\mingw\bin\gcc.exe`

If these paths change, update:

- `cpp_compiler`
- `c_compiler`

inside `nvim/lua/conf/keymap.lua`.

## C/C++ output assumptions

The `F5` workflow builds the current file into:

`<current_file_stem>.exe`

The `F6` workflow then runs that `.exe` directly in the dedicated build terminal pane.

That is Windows-specific in two ways:

- output file name uses the `.exe` extension
- file paths are composed with backslashes

## clangd path

`clangd` is configured with an explicit Windows path in `nvim/lua/conf/plugins/lsp.lua`:

`C:\Program Files\LLVM\bin\clangd.exe`

The config also uses:

`--query-driver=**`

because this machine has multiple compiler installations and `clangd` needs to query the real driver to resolve standard library headers correctly.

## Clipboard behavior

In `nvim/lua/conf/options.lua`, clipboard is set to:

`unnamedplus`

On this machine that means Neovim uses the Windows system clipboard.

## Neovide GUI font

The current GUI font is set in `nvim/lua/conf/options.lua`:

`Consolas:h11`

This is independent from terminal font settings. `Neovide` uses `guifont`, not the Windows Terminal font stack.

## Windows Terminal font

The current Windows Terminal settings are stored in:

`windows_terminal.settings.json`

The active terminal font is configured as:

`JetBrainsMono NF`

This matters for:

- `lualine` glyphs
- `nvim-web-devicons`
- other Nerd Font / powerline-style symbols in terminal Neovim

If terminal-side icons become corrupted again, check the live Windows Terminal file at:

`C:\Users\A\AppData\Local\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json`

and confirm the `profiles.defaults.font.face` entry still matches the expected Nerd Font.

## Neovide notes

This repository includes `nvim/lua/conf/neovide.lua`.

It is only loaded when:

`vim.g.neovide`

is present, so terminal Neovim does not use those settings.

Current Windows GUI-specific behavior includes:

- forcing a dark background and `tokyonight-night`
- cursor animation settings
- scroll animation settings
- `Ctrl+=`, `Ctrl+-`, `Ctrl+0` zoom controls

## CMake workflow assumptions

The `F7` and `F8` workflow assumes a build directory named:

`build-clangd`

and expects the project root to contain:

- `CMakeLists.txt`
- `.clangd`

The current workflow is tuned for a Windows local development setup rather than a generic cross-platform dotfiles repo.
