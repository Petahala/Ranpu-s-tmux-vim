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

- `F5` single-file C/C++ build and run
- `F6` refreshing `build-clangd/compile_commands.json`
- `F7` building the CMake project

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

and then runs that `.exe` directly.

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

## GUI font

The current GUI font is set in `nvim/lua/conf/options.lua`:

`Consolas:h11`

This was chosen because `JetBrainsMono Nerd Font` was not available in the active GUI environment at the time.

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

The `F6` and `F7` workflow assumes a build directory named:

`build-clangd`

and expects the project root to contain:

- `CMakeLists.txt`
- `.clangd`

The current workflow is tuned for a Windows local development setup rather than a generic cross-platform dotfiles repo.
