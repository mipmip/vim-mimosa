## Context

vim-nomisa is a single-file VimL plugin (`plugin/nomisa.vim`, 95 lines) that opens files in external applications based on their extension. It parses markdown image links or visual selections to extract file paths, optionally copies a template if the file doesn't exist, and launches the configured handler (inkscape, gimp, etc.).

The plugin currently uses VimL globals (`g:nomisa_templates_path`, `g:nomisa_extension_handlers`) for configuration and exposes two commands (`:Nomisa`, `:NomisaVisSel`). There are no tests.

The devshell already includes lua_ls, plenary, and treesitter — ready for this port.

## Goals / Non-Goals

**Goals:**
- 1:1 feature parity with the VimL version
- Idiomatic Lua module structure with `setup()` configuration pattern
- Testable: pure functions where possible, plenary test coverage
- Hot-reloadable in the devshell (`<Space>rr`)

**Non-Goals:**
- Adding new features (async launching, telescope picker, etc.)
- Supporting Vim (non-Neovim) — Lua modules require Neovim
- Changing the template directory layout

## Decisions

### Module structure: separate concerns into config/template/parse

```
lua/nomisa/
  init.lua       -- public API: setup(), command registration
  config.lua     -- defaults + merge logic
  template.lua   -- file operations: find template, copy, launch handler
  parse.lua      -- text parsing: extract paths from lines/selections
```

**Rationale:** Separating parse and template logic makes them independently testable without needing vim buffer state. `init.lua` is the glue that wires config + parse + template together behind commands.

**Alternative considered:** Single `init.lua` with everything inline. Rejected — harder to test, harder to navigate as the plugin grows.

### Config pattern: `setup()` with deep merge over defaults

```lua
-- User calls:
require("nomisa").setup({
  extension_handlers = {
    svg = "inkscape",
    kra = "krita",  -- user adds new handler
  },
})
```

Config merges with `vim.tbl_deep_extend("force", defaults, user_opts)`. Templates path defaults to auto-detected plugin root + `/nomisa_templates/`.

**Rationale:** This is the standard Neovim plugin convention (telescope, lualine, etc.). Users expect `setup()`. Deep merge means users only specify overrides, not the full table.

**Alternative considered:** Keep using `g:` globals. Rejected — doesn't follow Lua plugin conventions, harder to validate, no merge semantics.

### Plugin loader: thin `plugin/nomisa.lua`

The loader just calls `require("nomisa").setup()` with no args (uses defaults). Users who want custom config call `setup()` from their own init.lua, which overrides the auto-setup.

**Rationale:** Keeps the plugin working out of the box without requiring explicit setup. The `setup()` call is idempotent — calling it twice with different config just updates the config table.

### Path resolution: relative to current buffer directory

Matching existing behavior: paths extracted from markdown links or visual selection are resolved relative to `vim.fn.expand("%:h")` (directory of the current buffer).

### External process launching: `vim.fn.system()` (synchronous)

Keep using synchronous `system()` calls for launching external handlers, matching the existing VimL behavior.

**Rationale:** The current approach works and is in scope as a 1:1 port. Async launching (via `vim.loop.spawn` or `jobstart`) is explicitly out of scope.

## Risks / Trade-offs

**[Breaking change for Vim users]** → This plugin likely only runs in Neovim already (markdown editing workflow), but the Lua port drops any theoretical Vim compatibility. Acceptable given Neovim is the target.

**[Auto-setup vs explicit setup]** → The thin loader auto-calls `setup()`. If a user's plugin manager loads the plugin before their config runs, defaults apply first. This is standard behavior (same as lualine, etc.) and `setup()` is idempotent, so calling it again with custom config just works.

**[Shell injection in `system()` calls]** → The existing VimL code passes unsanitized paths to `system()`. The Lua port should use `vim.fn.shellescape()` on file paths passed to shell commands. This is a small improvement over the VimL version, justified by correctness.
