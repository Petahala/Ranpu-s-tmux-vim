# clangd Notes

This repo stores the Neovim-side `clangd` setup, but some `clangd` behavior is project-local rather than global.

## Why this matters

A common C++ annoyance is a yellow warning for an unused header, for example:

- `#include <iostream>` is present
- the file builds fine
- but `clangd` shows an "unused include" warning

That warning is not controlled by the Neovim UI alone. It is better handled in a project-local `.clangd` file.

## Current project-local fix

In a project root, create a `.clangd` file like this:

```yaml
CompileFlags:
  CompilationDatabase: build-clangd
Diagnostics:
  UnusedIncludes: None
```

## What each part does

- `CompilationDatabase: build-clangd`
  tells `clangd` to read `compile_commands.json` from `build-clangd`
- `UnusedIncludes: None`
  disables only the unused include warning

This keeps other diagnostics active.

## Scope

This setting is project-local.

- Put it in a project root if only that project should ignore unused includes
- Do not assume every C++ project should use the same rule

## After editing `.clangd`

Reload `clangd` in Neovim:

```vim
:LspRestart
```

or reopen the file/editor.
