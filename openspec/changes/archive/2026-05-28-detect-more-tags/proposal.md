# Detect More Image/File Tags

**Status**: proposed
**Schema**: spec-driven
**Bean**: vim-mimosa-rwkf

## Problem

Mimosa currently only detects paths inside parentheses `(path)`, which covers markdown image/link syntax. Users working with HTML content or Claude Code output encounter `<img src="...">` tags and `@filepath` references that Mimosa cannot open. Additionally, `:Mimosa` always grabs the first match on a line — when a line has multiple references, the user has no way to target a specific one without visual selection.

## Solution

Extend `parse.lua` with three extraction strategies (markdown, HTML img, @filepath), return all matches with their positions, and pick the one closest to the cursor. Add validation for invalid combinations (e.g. `@` inside markdown syntax).

### Extraction strategies (in chain order)

1. **Markdown** — `![...](path)` or `[...](path)` — extract content between `(` and `)` following `]`
2. **HTML img** — `<img ... src="path" ...>` — extract `src` attribute value, supporting double quotes, single quotes, and unquoted values; `src` can appear at any attribute position
3. **@filepath** — `@` followed by non-whitespace characters — greedy match, strip trailing punctuation (`.,;:!?)`)

### Cursor-aware selection

All strategies run against the full line. Each match records its start/end column positions. The match closest to the cursor column is selected. This replaces the current "first match wins" behavior.

### Validation in parse

After extraction, validate the path in `parse.lua` before returning:
- If a markdown match contains `@` at the start of the path (e.g. `![img](@some/path.png)`), return an error message instead of the path — this is not a valid combination

### Command integration

`:Mimosa` passes `vim.fn.col(".")` into the parse layer. `:MimosaVisSel` is unchanged (explicit selection needs no cursor heuristic).

## Scope

### In scope
- Multi-strategy path extraction (markdown, HTML img, @filepath)
- Cursor-proximity match selection
- Validation for `@` inside markdown syntax
- Tests for all new patterns and edge cases
- Update path-parsing spec

### Out of scope
- Multiline HTML tag parsing (only single-line `<img>` tags)
- New extension handlers or template types
- Changes to template.lua or config.lua
- Telescope/picker for multiple matches

## Approach

1. Rewrite `parse.extract_path_from_line(line, col)` to return closest match
2. Add internal extractors: `extract_markdown_paths`, `extract_html_img_paths`, `extract_at_paths`
3. Add `pick_closest(matches, col)` helper
4. Add validation step for invalid combinations
5. Update `init.lua` to pass cursor column to parse
6. Update tests and spec
