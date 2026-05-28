# Rename Project to vim-mimosa

**Status**: proposed
**Schema**: spec-driven
**Bean**: vim-nomisa-j8k6

## Problem

The name "nomisa" has no meaning. The plugin deserves a name that communicates what it does.

## Solution

Rename the project to **vim-mimosa** — **M**edia **I**n **M**arkdown **O**pener for **S**pecialized **A**pplications.

This involves renaming across the entire codebase: Lua module paths, commands, config variables, flake.nix references, README, templates directory, and displaying the new logo.

## Scope

### In scope
- Rename all `nomisa` references to `mimosa` in source code
- Rename directories: `lua/nomisa/` → `lua/mimosa/`, `tests/nomisa/` → `tests/mimosa/`
- Rename template directory: `nomisa_templates/` → `mimosa_templates/`
- Rename commands: `:Nomisa` → `:Mimosa`, `:NomisaVisSel` → `:MimosaVisSel`
- Rename config vars: `nomisa_disable_autosetup` → `mimosa_disable_autosetup`
- Update flake.nix: env var, reload function, banner, rtp references
- Update README: title, description, acronym explanation, installation instructions (repo name), configuration examples, show `mimosa-logo.png`
- Update openspec main specs to reflect new names
- Update `.beans.yml` prefix

### Out of scope
- Renaming the GitHub repository (that's a manual step by the maintainer)
- Renaming archived openspec changes (historical record)
- Renaming `.beans/` task filenames (they use fixed IDs)
