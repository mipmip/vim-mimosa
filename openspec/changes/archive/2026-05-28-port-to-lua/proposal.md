# Port Nomisa to Lua

**Status**: proposed
**Schema**: spec-driven

## Problem

vim-nomisa is written entirely in VimL (`plugin/nomisa.vim`, 95 lines). VimL is harder to test, harder to extend, and lacks the ecosystem/tooling that Lua has in the Neovim world. The devshell already includes lua_ls and plenary in anticipation of this port.

## Solution

Rewrite the plugin in Lua, maintaining the same functionality and user-facing commands (`:Nomisa`, `:NomisaVisSel`). Add plenary-based tests.

### Current functionality to port

1. **Config** — `g:nomisa_templates_path` (auto-detected from plugin path), `g:nomisa_extension_handlers` (maps extensions to external programs: svg→inkscape, png/jpg/gif→gimp)
2. **`get_extension_handler(ext)`** — looks up handler program for a file extension
3. **`get_template_file(ext)`** — finds a template file in `nomisa_templates/<ext>/`
4. **`open_template(path)`** — core logic: given a relative path, resolves it against the current buffer's directory, creates parent dirs if needed, copies template if file doesn't exist, opens in external handler if one is configured
5. **`:Nomisa`** — parses current line for a markdown image link `![](path)` and calls open_template on the path
6. **`:NomisaVisSel`** — uses visual selection as the path and calls open_template

### Target structure

```
lua/
  nomisa/
    init.lua          -- setup(), config, commands
    config.lua        -- default config + user overrides via setup()
    template.lua      -- get_template_file, open_template, get_extension_handler
    parse.lua         -- extract_path_from_line, extract_path_from_selection
plugin/
  nomisa.lua          -- thin loader: require("nomisa").setup()
tests/
  minimal_init.lua    -- plenary test bootstrap
  nomisa/
    template_spec.lua -- tests for template logic
    parse_spec.lua    -- tests for path extraction
```

## Scope

### In scope
- Port all VimL functionality to Lua modules
- `setup()` function for user configuration (replaces `g:` globals)
- Thin `plugin/nomisa.lua` loader
- Plenary-based tests for template and parse logic
- Remove old `plugin/nomisa.vim`

### Out of scope
- New features (this is a 1:1 port)
- Changing template file structure
- Telescope/fzf integration for template selection
- Async external program launching

## Approach

1. Create the Lua module structure
2. Port config (with `setup()` for user overrides, sensible defaults matching current globals)
3. Port template logic (get_handler, get_template, open_template)
4. Port path parsing (line parser for `![](path)`, visual selection parser)
5. Wire up commands in init.lua
6. Add thin plugin loader
7. Write tests
8. Remove old VimL file
