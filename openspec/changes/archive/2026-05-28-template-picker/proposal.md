# Template Picker and AI Workflow Enhancements

**Status**: proposed
**Schema**: spec-driven
**Bean**: vim-nomisa-wt61

## Problem

When multiple templates exist for an extension, Mimosa silently picks the first one. Users have no way to choose between e.g. an empty SVG canvas and a wireframe template. Additionally, the README doesn't explain how Mimosa fits into AI-assisted workflows despite having full support for it.

## Solution

1. Show `vim.ui.select` when multiple templates exist for an extension
2. Add more SVG templates (empty canvas, wireframe)
3. Add README section for AI coding assistant workflows

### Template picker

```
get_template_file("svg")
  1 template   → return it (no prompt, same as today)
  0 templates  → return nil (same as today)
  2+ templates → vim.ui.select with filenames → return chosen
```

### Async change

`get_template_file` becomes async (callback-based) when multiple templates exist. `open_template` must be refactored to handle this — the create-and-open flow becomes callback-driven.

### New templates

```
mimosa_templates/svg/
  empty-canvas.svg          (rename from tpl960x700.svg)
  wireframe-960x700.svg     (new: grid layout for wireframing)
```

## Scope

### In scope
- Template picker via `vim.ui.select` when 2+ templates
- Refactor `open_template` to handle async template selection
- Add wireframe SVG template
- Rename existing SVG template for clarity
- README section on AI workflow + recommended handlers

### Out of scope
- Templates for non-SVG formats
- Template preview
- Template creation/management commands
