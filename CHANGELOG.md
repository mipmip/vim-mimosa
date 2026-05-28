# Changelog

## 2026-05-28 — Default handler for all file formats

- Added `default_handler` config with platform auto-detection (xdg-open/open/start)
- Any file reference can now be opened, not just svg/png/jpg/gif
- Suppressed "no template" warning for extensions without explicit handlers

## 2026-05-28 — Create new files with :MimosaNew

- Added `:MimosaNew [ext] [path]` command for creating new file references
- Interactive flow: filetype picker (`vim.ui.select`) + path prompt (`vim.ui.input`)
- Filetype-aware tag insertion: `![](path)` for markdown/quarto, `<img src="path">` for html
- Extension auto-appending with duplicate detection
- Absolute path validation (parent dir must exist)
- Added `lua/mimosa/insert.lua` module
- Updated README with Commands table and Recommended Keybindings section

## 2026-05-28 — Detect more image/file tags

- Added HTML `<img src="...">` tag detection (double, single, and unquoted)
- Added `@filepath` reference detection (greedy, with trailing punctuation stripping)
- Added cursor-aware match selection (picks closest match on line)
- Added validation error for `@` inside markdown syntax
- Tightened markdown matching to require `](` prefix (bare parens no longer match)
- Updated README with supported formats and examples
