## Context

Mimosa has a hardcoded set of extension handlers (svg→inkscape, png/jpg/gif→gimp). Files with other extensions are silently ignored by `:Mimosa`.

## Goals / Non-Goals

**Goals:**
- Any file reference can be opened via `:Mimosa`
- Zero-config: auto-detect platform opener

**Non-Goals:**
- Templates for new formats
- Changes to `:MimosaNew`

## Decisions

### Auto-detect default handler

```lua
local function detect_opener()
  if vim.fn.has("mac") == 1 then return "open" end
  if vim.fn.has("win32") == 1 then return "start" end
  return "xdg-open"
end
```

Added to `defaults` in `config.lua`. User can override via `setup()`.

### Fallback in get_extension_handler

```lua
function M.get_extension_handler(ext)
  return config.values.extension_handlers[ext]
      or config.values.default_handler
end
```

### Suppress template warning for unconfigured extensions

`get_template_file` currently warns when no template is found. Add a check: only warn if the extension has an explicit handler configured (i.e. the user expects templates to exist for it).

### No file creation for fallback

`open_template` already skips creation when no template exists. The only change is that `get_extension_handler` now returns a handler (the fallback), so existing files will be opened. Non-existent files without templates still result in no action — the `filereadable` check prevents launching the handler on a missing file.
