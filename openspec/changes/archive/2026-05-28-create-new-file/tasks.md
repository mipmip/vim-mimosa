# Tasks: Create Shortcuts and Menus for Creating New Files

## Tasks

- [x] Create `lua/mimosa/insert.lua` — `format_tag(path, filetype)` returns the tag string based on buffer filetype (markdown/quarto → `![](path)`, html → `<img src="path">`, fallback → markdown)
- [x] Add `insert_tag_at_cursor(tag)` to `insert.lua` — inserts tag text at current cursor position using `vim.api.nvim_put`
- [x] Add path resolution logic — append extension if not already present, validate absolute paths (parent dir must exist), resolve relative paths against buffer directory
- [x] Add `:MimosaNew` command to `init.lua` — parses optional `[ext] [path]` arguments
- [x] Wire up `vim.ui.select` for extension picker — shows sorted keys from `extension_handlers`, validates ext arg against configured handlers
- [x] Wire up `vim.ui.input` for path prompt — handles cancellation and empty input gracefully
- [x] Connect the full flow: pick ext → prompt path → resolve path → insert tag → `template.open_template(path)`
- [x] Write tests for `format_tag` (markdown, quarto, html, unknown filetype)
- [x] Write tests for extension appending (without ext, with correct ext, with wrong ext)
- [x] Write tests for absolute path validation (existing parent, missing parent)
- [x] Update README with `:MimosaNew` docs and recommended keybinding examples
- [x] Update openspec specs
