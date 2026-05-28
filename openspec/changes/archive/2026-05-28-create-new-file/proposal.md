# Create Shortcuts and Menus for Creating New Files

**Status**: proposed
**Schema**: spec-driven
**Bean**: vim-nomisa-cuxe

## Problem

Mimosa can only open existing file references found in the buffer. There's no way to create a new file from scratch — the user must manually type `![](images/file.svg)`, position their cursor, and run `:Mimosa`. This is friction-heavy for the primary use case: quickly sketching a new diagram or image while writing a presentation.

## Solution

Add a `:MimosaNew [ext]` command that:
1. Picks a filetype (via `vim.ui.select` from configured handlers, or directly if ext is provided)
2. Prompts for a file path (via `vim.ui.input`)
3. Inserts the appropriate tag at the cursor based on buffer filetype
4. Creates the file from template and opens it in the handler

No default keybindings — only commands. README shows recommended mappings.

### Tag format by buffer filetype

| Buffer filetype | Inserted tag |
|-----------------|-------------|
| markdown, quarto | `![](path)` |
| html | `<img src="path">` |
| other (fallback) | `![](path)` |

### Path handling

- Relative paths: create parent directories with `mkdir -p`
- Absolute paths: parent directory must already exist (error if not)
- Path is resolved relative to current buffer's directory (same as `:Mimosa`)

## Scope

### In scope
- `:MimosaNew [ext]` command with optional extension argument
- `vim.ui.select` picker for extension (from configured `extension_handlers`)
- `vim.ui.input` prompt for file path
- Filetype-aware tag insertion at cursor position
- File creation from template + handler launch
- Documentation with recommended keybinding examples

### Out of scope
- Default keybindings (commands only)
- Telescope/fzf integration
- Auto-generated filenames
- `@filepath` as an insertion format
- New templates or extension handlers

## Approach

1. Add tag insertion logic (filetype-aware) to a new module or extend template.lua
2. Add `:MimosaNew` command to init.lua
3. Wire up `vim.ui.select` → `vim.ui.input` → insert + create + open flow
4. Write tests for tag format selection and path validation
5. Update README with new command and recommended mappings
6. Update specs
