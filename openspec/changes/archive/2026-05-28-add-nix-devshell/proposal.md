# Add Nix Devshell

**Status**: proposed
**Schema**: spec-driven

## Problem

vim-nomisa has no isolated development environment. Developing and testing the plugin requires manually configuring neovim, and there's no reproducible setup for contributors or for the upcoming Lua port.

## Solution

Add a `flake.nix` that provides an isolated NixVim-based development shell, following the same pattern as [linny.vim](~/cLinden/linny.vim/flake.nix).

The devshell provides:
- A NixVim-built neovim with the plugin on the runtimepath
- XDG directory isolation (`.dev/`) so it doesn't touch the user's main neovim config
- `NOMISA_DEV_PATH` env var for live source reloading
- Lua cache-clearing reload function + VimL re-sourcing (`<Space>rr`)
- Plenary test runner keymap (`<Space>rt`)
- lua_ls + stylua for the upcoming Lua port
- Treesitter with all grammars

## Scope

### In scope
- `flake.nix` with NixVim devshell
- XDG isolation via `.dev/` directory
- Live reload support (Lua modules `^nomisa` + VimL `plugin/nomisa.vim`)
- lua_ls LSP configured with vim globals
- Plenary-based test runner keymap
- `.gitignore` entry for `.dev/`

### Out of scope
- Writing actual tests (separate change)
- Porting to Lua (separate change)
- CI/CD integration
- Multi-architecture support (x86_64-linux only for now)

## Approach

Adapt linny.vim's `flake.nix` with nomisa-specific paths and globals. Strip out linny-specific config (notebook paths, hugo flags). Keep the full NixVim + lua_ls + plenary + treesitter stack since the Lua port is planned.
