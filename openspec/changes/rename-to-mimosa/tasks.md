# Tasks: Rename to vim-mimosa

## Tasks

- [x] Rename directories: `lua/nomisa/` → `lua/mimosa/`, `tests/nomisa/` → `tests/mimosa/`, `nomisa_templates/` → `mimosa_templates/`
- [x] Update all Lua source files: replace `nomisa` with `mimosa` in requires, module names, config keys, notify messages, command names, reload patterns
- [x] Update `plugin/nomisa.lua` → `plugin/mimosa.lua` (rename file + update contents)
- [x] Update `tests/minimal_init.lua`: `nomisa_disable_autosetup` → `mimosa_disable_autosetup`
- [x] Update `flake.nix`: env var `NOMISA_DEV_PATH` → `MIMOSA_DEV_PATH`, reload function, banner text, rtp references
- [x] Update README: title to "vim-mimosa", add acronym explanation, show `mimosa-logo.png`, update installation instructions and configuration examples
- [x] Update openspec main specs: rename Nomisa/NomisaVisSel command references to Mimosa/MimosaVisSel
- [x] Update `.beans.yml` prefix from `vim-nomisa-` to `vim-mimosa-`
- [x] Update `images/about-nomisa.svg` reference if used
- [x] Verify in devshell: `:Mimosa` and `:MimosaVisSel` work, reload works, all tests pass
