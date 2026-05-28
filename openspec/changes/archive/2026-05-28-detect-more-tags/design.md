## Context

Mimosa's `parse.lua` currently has a single extraction strategy: find the first `(...)` on a line. This works for markdown image links but misses HTML img tags and @filepath references. The `:Mimosa` command doesn't use cursor position, so when multiple references exist on one line, it always grabs the first.

## Goals / Non-Goals

**Goals:**
- Support markdown, HTML img, and @filepath extraction
- Cursor-aware: pick the match closest to the cursor
- Validate invalid combinations with informative errors
- All extraction logic stays in `parse.lua`

**Non-Goals:**
- Multiline HTML parsing
- Configurable/user-extensible patterns
- Changes to template.lua or config.lua

## Decisions

### Architecture: chain of extractors returning all matches

```
extract_path_from_line(line, col)
  │
  ├─ extract_markdown_paths(line)   → [{path, start, end}, ...]
  ├─ extract_html_img_paths(line)   → [{path, start, end}, ...]
  ├─ extract_at_paths(line)         → [{path, start, end}, ...]
  │
  ├─ combine all matches
  ├─ validate(matches)              → filter/error invalid combos
  ├─ pick_closest(matches, col)     → single match
  │
  └─ return path, err
```

**Rationale:** Each extractor is a pure function that takes a string and returns matches with positions. Easy to test independently. The chain approach means adding a new format later is just adding another extractor.

**Alternative considered:** Pattern registry (config-driven, user-extensible). Rejected — unnecessary complexity for three well-known formats.

### Markdown extractor: `](`...`)` pattern

Match `](` followed by content up to `)`. This is more precise than the current "first parens" approach — it requires the `](` prefix that markdown links always have.

**Breaking change:** Bare `(content)` without a preceding `]` will no longer match. The current test `"some text (with parens)"` returns `"with parens"` — this will stop working. This is acceptable: bare parens are not a file reference format Mimosa should support.

### HTML img extractor: regex-based

Pattern: `<img%s+(.-)>` to capture attributes, then extract `src` value.

Supports:
- `src="path"` (double quotes)
- `src='path'` (single quotes)
- `src=path` (unquoted, terminated by space or `>`)
- `src` at any attribute position

Single-line only. If `<img` and `>` aren't on the same line, no match.

### @filepath extractor: greedy with punctuation stripping

Pattern: `@` followed by one or more non-whitespace characters. After matching, strip trailing punctuation: `.,;:!?)`.

```
@/home/pim/file.png          → /home/pim/file.png
@images/diagram.svg           → images/diagram.svg
@file.png.                    → file.png      (trailing . stripped)
see @path/to/img.png,         → path/to/img.png (trailing , stripped)
```

**Rationale:** Greedy is simpler and handles more cases. Punctuation stripping handles the common case of references in prose. The `@` prefix is unambiguous enough that false positives are unlikely in the context of files Mimosa operates on (markdown, notes).

### Cursor proximity: absolute distance to match range

```lua
function pick_closest(matches, col)
  -- If col is inside a match range, distance = 0
  -- Otherwise, distance = min(|col - start|, |col - end|)
  -- Ties: prefer the match that comes first on the line
end
```

### Validation: @-inside-markdown error

After collecting all matches, check if any markdown match has a path starting with `@`. If so, return `nil` and an error string. The caller (init.lua) displays the error via `vim.notify`.

```lua
local path, err = parse.extract_path_from_line(line, col)
if err then
  vim.notify(err, vim.log.levels.ERROR)
  return
end
```

**Rationale:** Validation in parse keeps the parse module self-contained. The error message is informative: tells the user what's wrong and how to fix it.

### API change: extract_path_from_line gains col parameter

```lua
-- Before
parse.extract_path_from_line(line)        → path or nil

-- After
parse.extract_path_from_line(line, col)   → path, err  (or nil, nil)
```

When `col` is nil, falls back to picking the first match (preserves usability for programmatic callers).

## Risks / Trade-offs

**[Breaking: bare parens no longer match]** → Tightening markdown to require `](` prefix means `"text (in parens)"` no longer extracts. This is intentional — bare parens were never a real use case, just a side effect of the loose pattern.

**[@filepath false positives]** → In files that use `@` for other purposes (email addresses, decorators), the extractor might match. Acceptable: Mimosa is triggered manually via `:Mimosa`, so a false match is easily ignored. Could refine later if it becomes a problem.

**[HTML attr parsing without a real parser]** → Lua pattern matching for HTML attributes is imperfect. Edge cases like attribute values containing `>` will break. Acceptable for the common case of `<img src="path">`.
