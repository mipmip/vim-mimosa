# Tasks: Template Picker and AI Workflow Enhancements

## Tasks

- [x] Refactor `get_template_file(ext, callback)` — callback-based, `vim.ui.select` when 2+ templates, immediate callback for 0 or 1
- [x] Refactor `open_template(path)` — wrap create-and-open in `get_template_file` callback
- [x] Rename `mimosa_templates/svg/tpl960x700.svg` to `empty-canvas.svg`
- [x] Create `mimosa_templates/svg/wireframe-960x700.svg` — 960x700 SVG with grid
- [x] Update tests for `get_template_file` (single, multiple, zero, cancellation)
- [x] Update tests for `open_template` to work with callback-based `get_template_file`
- [x] Add AI workflow section to README + recommended handler config
- [x] Update openspec specs
