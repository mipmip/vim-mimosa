# Tasks: Detect More Image/File Tags

## Tasks

- [x] Add `extract_markdown_paths(line)` — returns list of `{path, start, end}` matches for `](path)` patterns
- [x] Add `extract_html_img_paths(line)` — returns list of matches for `<img src="path">` (double/single/unquoted)
- [x] Add `extract_at_paths(line)` — returns list of matches for `@filepath`, greedy with trailing punctuation stripping
- [x] Add `pick_closest(matches, col)` — selects match nearest to cursor column, first-on-line tiebreak
- [x] Add validation: `@` at start of markdown-extracted path returns nil + error message
- [x] Rewrite `extract_path_from_line(line, col)` — chains extractors, validates, picks closest
- [x] Update `init.lua` `:Mimosa` command to pass `vim.fn.col(".")` to `extract_path_from_line`
- [x] Update `init.lua` to handle error return from parse (display via `vim.notify`)
- [x] Write tests for markdown extractor (standard, empty alt, link, spaces, bare parens rejection)
- [x] Write tests for HTML img extractor (double/single/unquoted quotes, src position, self-closing)
- [x] Write tests for @filepath extractor (absolute, relative, bare, punctuation stripping)
- [x] Write tests for cursor proximity selection (near first, near second, inside, tiebreak, nil col)
- [x] Write tests for @-inside-markdown validation error
- [x] Update `openspec/specs/path-parsing/spec.md` with final spec
