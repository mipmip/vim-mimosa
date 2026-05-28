# Tasks: Port Nomisa to Lua

## Tasks

- [x] Create `lua/nomisa/config.lua` — default config table (templates_path auto-detected, extension_handlers with svg/png/jpg/gif defaults), `setup()` merges user overrides
- [x] Create `lua/nomisa/template.lua` — `get_extension_handler(ext)`, `get_template_file(ext)`, `open_template(path)` (resolve against buffer dir, mkdir, copy template, launch handler)
- [x] Create `lua/nomisa/parse.lua` — `extract_path_from_line(line)` (parses `![](path)` or `(path)` patterns), `extract_path_from_selection()` (gets visual selection text)
- [x] Create `lua/nomisa/init.lua` — `setup()` entry point, register `:Nomisa` and `:NomisaVisSel` commands
- [x] Create `plugin/nomisa.lua` — thin loader that calls `require("nomisa").setup()`
- [x] Create `tests/minimal_init.lua` — plenary test bootstrap that adds plugin to runtimepath
- [x] Create `tests/nomisa/template_spec.lua` — tests for get_template_file, get_extension_handler, open_template (with temp dirs)
- [x] Create `tests/nomisa/parse_spec.lua` — tests for extract_path_from_line (markdown image links, bare parens, edge cases)
- [x] Remove `plugin/nomisa.vim`
- [x] Verify in devshell: `:Nomisa` and `:NomisaVisSel` work, `<Space>rr` reloads Lua modules, `<Space>rt` runs tests
