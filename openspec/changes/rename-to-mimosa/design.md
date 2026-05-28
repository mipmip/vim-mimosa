## Context

The plugin was recently ported from VimL to Lua. All references currently use "nomisa". The rename touches every layer: Lua modules, plugin loader, test files, flake.nix devshell, README, templates directory, and openspec specs.

## Goals / Non-Goals

**Goals:**
- Every user-facing and developer-facing reference says "mimosa"
- Plugin works identically after rename — only names change
- README explains the acronym and shows the logo

**Non-Goals:**
- Renaming the GitHub repo (manual step, not codeable)
- Renaming historical archives (they're a record of what was)
- Renaming bean task files (fixed IDs)

## Decisions

### Rename strategy: comprehensive find-and-replace with directory moves

Rename in this order to avoid broken requires mid-change:
1. Rename directories first (`lua/nomisa/` → `lua/mimosa/`, `tests/nomisa/` → `tests/mimosa/`, `nomisa_templates/` → `mimosa_templates/`)
2. Then update all file contents (module requires, config references, commands, etc.)
3. Then update README with new name, acronym, and logo

**Rationale:** Directory renames must happen before content changes, otherwise `require("mimosa.config")` would fail if `lua/mimosa/` doesn't exist yet.

### Command names: `:Mimosa` and `:MimosaVisSel`

Direct rename, same pattern. No aliasing of old names.

**Rationale:** This is a clean break. No backwards compatibility needed since the Lua port is also new.

### README: add acronym explanation and logo

Add the mimosa-logo.png image and explain the acronym near the top: "**MIMOSA** — **M**edia **I**n **M**arkdown **O**pener for **S**pecialized **A**pplications"

## Risks / Trade-offs

**[Breaking change for existing users]** → Anyone using `:Nomisa` or `require("nomisa")` will break. Acceptable since the Lua port itself is already a breaking change and this project is early-stage.

**[Template directory rename]** → Users with custom `templates_path` pointing to `nomisa_templates/` will need to update. The default auto-detects from plugin root, so most users are unaffected.
