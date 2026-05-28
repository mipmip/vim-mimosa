## Context

`template.lua` has two key functions: `get_template_file(ext)` which finds templates, and `open_template(path)` which orchestrates create-and-open. Both are synchronous. Adding `vim.ui.select` for template choice makes `get_template_file` async, which cascades into `open_template`.

`open_template` is called from three places:
- `:Mimosa` in `init.lua`
- `:MimosaVisSel` in `init.lua`
- `:MimosaNew` in `init.lua` (already callback-based)

## Goals / Non-Goals

**Goals:**
- Let users choose between templates when multiple exist
- Keep single-template case unchanged (no prompt)
- Descriptive template filenames

**Non-Goals:**
- Template preview or thumbnails
- Templates for new formats beyond SVG

## Decisions

### Refactor open_template to callback style

```lua
-- Before (sync)
function M.open_template(path)
  ...
  local tpl_file = M.get_template_file(file_ext)
  ...
end

-- After (async when needed)
function M.open_template(path)
  ...
  M.get_template_file(file_ext, function(tpl_file)
    if tpl_file then
      vim.fn.system({ "cp", tpl_file, file_path })
    end
    -- open handler
    ...
  end)
end
```

**Rationale:** The callback only fires when there's a picker (2+ templates). For 0 or 1 template, the callback is invoked immediately — no UI prompt, no async. Callers of `open_template` don't change since it was already fire-and-forget (no return value used).

### get_template_file becomes callback-based

```lua
function M.get_template_file(ext, callback)
  local files = ...
  if #files == 0 then ... callback(nil); return end
  if #files == 1 then callback(files[1]); return end
  -- 2+ files: pick
  local names = map filenames for display
  vim.ui.select(names, { prompt = "Mimosa: select template" }, function(choice, idx)
    if idx then callback(files[idx]) else callback(nil) end
  end)
end
```

**Rationale:** The callback pattern keeps the function testable — tests pass a synchronous callback. `vim.ui.select` cancellation (nil choice) is handled by passing nil to the callback.

### Template filenames as labels

Display just the filename (not full path) in the picker:

```
Mimosa: select template
> empty-canvas.svg
  wireframe-960x700.svg
```

**Rationale:** Filenames are user-controlled and self-documenting. No need for a separate metadata/description system.

### SVG templates

- `empty-canvas.svg` — renamed from `tpl960x700.svg`, clean 960x700 SVG
- `wireframe-960x700.svg` — new, 960x700 with a subtle grid for wireframing

### No changes to callers

`:Mimosa`, `:MimosaVisSel`, and `:MimosaNew` all call `open_template` as fire-and-forget. The async change is internal to `template.lua` — no caller changes needed.

## Risks / Trade-offs

**[Callback complexity]** → `open_template` gains one level of nesting. Acceptable for a single callback. If more async steps are needed later, consider switching to coroutines.

**[Template rename is breaking]** → Renaming `tpl960x700.svg` to `empty-canvas.svg` changes the filename. Users with custom `templates_path` pointing to the plugin directory would see the rename. Unlikely to affect anyone — custom paths typically point elsewhere.
