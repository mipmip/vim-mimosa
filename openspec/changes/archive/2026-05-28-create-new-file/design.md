## Context

Mimosa currently has two commands: `:Mimosa` (parse current line, open file) and `:MimosaVisSel` (use visual selection as path, open file). Both require an existing file reference in the buffer. This change adds `:MimosaNew` to create a new file reference from scratch.

The plugin has three modules: `config.lua` (settings), `parse.lua` (text extraction), `template.lua` (file operations). The new command introduces a fourth concern: tag insertion into the buffer.

## Goals / Non-Goals

**Goals:**
- Single command to go from nothing to an open external editor
- Filetype-aware tag insertion (markdown vs html)
- Consistent with existing path resolution and template logic
- No default keybindings

**Non-Goals:**
- Telescope integration
- Auto-generated filenames or directory paths
- Async UI flows

## Decisions

### New module: `insert.lua`

Tag insertion is a distinct concern from parsing or template handling. A new `insert.lua` module owns:
- Determining the tag format based on buffer filetype
- Inserting text at the cursor position

```
lua/mimosa/
  init.lua       -- commands
  config.lua     -- settings
  parse.lua      -- extract paths from text
  template.lua   -- file operations (create, open)
  insert.lua     -- insert tags into buffer  ← new
```

**Rationale:** Keeps modules single-purpose. `parse.lua` extracts paths from text, `insert.lua` puts them back. Symmetry.

**Alternative considered:** Adding insert functions to `template.lua`. Rejected — template.lua deals with files on disk, not buffer manipulation.

### Command: `:MimosaNew [ext]`

```
:MimosaNew           → vim.ui.select picker → vim.ui.input → insert + create + open
:MimosaNew svg       → skip picker → vim.ui.input → insert + create + open
:MimosaNew svg foo   → skip picker, skip prompt, path = "foo.svg" → insert + create + open
```

The third form (both args) enables one-shot keymaps and scripting.

### Picker source: `extension_handlers` keys

`vim.ui.select` shows only extensions that have a handler configured. This ensures every option in the picker actually works.

```lua
local exts = vim.tbl_keys(config.values.extension_handlers)
table.sort(exts)
vim.ui.select(exts, { prompt = "Mimosa: select filetype" }, function(ext) ... end)
```

### Path prompt: `vim.ui.input`

After extension is chosen, prompt for the path:

```lua
vim.ui.input({ prompt = "Mimosa: file path (e.g. images/diagram): " }, function(input) ... end)
```

The user enters a path without extension — the extension is appended automatically. If the user includes the extension, don't double it.

### Tag format by filetype

```lua
local tag_formats = {
  markdown = "![](${path})",
  quarto   = "![](${path})",
  html     = '<img src="${path}">',
}
-- fallback: markdown format
```

Detection uses `vim.bo.filetype`.

### Insert at cursor

Use `vim.api.nvim_put` to insert the tag at the current cursor position in the current line. This respects normal mode cursor semantics.

### Path handling

- **Relative path** (no leading `/`): resolved relative to buffer directory. Parent dirs created with `mkdir -p`.
- **Absolute path** (leading `/`): used as-is. Parent directory must exist — error via `vim.notify` if it doesn't.

This reuses `template.open_template`'s existing path resolution and mkdir logic for relative paths. For absolute paths, a validation check is added before calling open_template.

### Flow diagram

```
:MimosaNew [ext] [path]
     │
     ├─ ext provided? ───yes───┐
     │                          │
     ├─ no                      │
     │   ▼                      │
     │  vim.ui.select           │
     │  (keys of ext_handlers)  │
     │   │                      │
     │   ▼                      │
     ├──────────────────────────┤
     │                          │
     ├─ path provided? ──yes───┐│
     │                         ││
     ├─ no                     ││
     │   ▼                     ││
     │  vim.ui.input           ││
     │  "file path:"           ││
     │   │                     ││
     │   ▼                     ││
     ├─────────────────────────┤│
     │                          │
     ▼                          ▼
  append ext if missing
     │
     ├─ absolute? validate parent dir exists
     │
     ▼
  insert tag at cursor (filetype-aware)
     │
     ▼
  template.open_template(path)
  (creates from template + opens handler)
```

### No default keybindings

Commands only. README documents recommended mappings:

```lua
vim.keymap.set("n", "<leader>mo", ":Mimosa<CR>")
vim.keymap.set("n", "<leader>mn", ":MimosaNew<CR>")
vim.keymap.set("n", "<leader>ms", ":MimosaNew svg<CR>")
```

## Risks / Trade-offs

**[vim.ui.select/input are async]** → Both `vim.ui.select` and `vim.ui.input` use callbacks. The flow is a chain of callbacks (select → input → insert → open). This is straightforward but means the logic reads as nested callbacks rather than sequential code. Acceptable for a 2-level nesting.

**[Extension appending heuristic]** → If user types `diagram.svg` and ext is `svg`, we need to not produce `diagram.svg.svg`. Check if the input already ends with `.ext` before appending. Simple string check.

**[Filetype detection edge cases]** → `vim.bo.filetype` may be empty for new/unsaved buffers. Fall back to markdown format, which is the primary use case.
