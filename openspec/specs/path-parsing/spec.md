## Requirements

### Requirement: Extract path from markdown image/link syntax
The plugin SHALL extract the file path from markdown link syntax `](path)` on the current line.

#### Scenario: Standard markdown image link
- **WHEN** the current line is `![alt text](images/diagram.svg)` and cursor is anywhere on the line
- **THEN** `extract_path_from_line` SHALL return `"images/diagram.svg"`

#### Scenario: Empty alt text
- **WHEN** the current line is `![](images/diagram.svg)`
- **THEN** `extract_path_from_line` SHALL return `"images/diagram.svg"`

#### Scenario: Markdown link (not image)
- **WHEN** the current line is `[click here](docs/guide.pdf)`
- **THEN** `extract_path_from_line` SHALL return `"docs/guide.pdf"`

#### Scenario: Path with spaces
- **WHEN** the current line is `![](my images/diagram.svg)`
- **THEN** `extract_path_from_line` SHALL return `"my images/diagram.svg"`

#### Scenario: Bare parentheses (no ] prefix)
- **WHEN** the current line is `some text (with parens)`
- **THEN** `extract_path_from_line` SHALL return nil

#### Scenario: No matches on line
- **WHEN** the current line is `just plain text`
- **THEN** `extract_path_from_line` SHALL return nil

### Requirement: Extract path from HTML img tag
The plugin SHALL extract the `src` attribute value from `<img>` tags on the current line.

#### Scenario: Double-quoted src
- **WHEN** the current line is `<img src="image.png">`
- **THEN** `extract_path_from_line` SHALL return `"image.png"`

#### Scenario: Single-quoted src
- **WHEN** the current line is `<img src='image.png'>`
- **THEN** `extract_path_from_line` SHALL return `"image.png"`

#### Scenario: Unquoted src
- **WHEN** the current line is `<img src=image.png>`
- **THEN** `extract_path_from_line` SHALL return `"image.png"`

#### Scenario: src not first attribute
- **WHEN** the current line is `<img alt="photo" src="team.jpg" width="100">`
- **THEN** `extract_path_from_line` SHALL return `"team.jpg"`

#### Scenario: Self-closing tag
- **WHEN** the current line is `<img src="image.png" />`
- **THEN** `extract_path_from_line` SHALL return `"image.png"`

### Requirement: Extract path from @filepath reference
The plugin SHALL extract file paths following `@` on the current line. The path is terminated by whitespace or end of line. Trailing punctuation (`.,;:!?)`) SHALL be stripped.

#### Scenario: Absolute path
- **WHEN** the current line is `see @/home/pim/file.png for details`
- **THEN** `extract_path_from_line` SHALL return `"/home/pim/file.png"`

#### Scenario: Relative path
- **WHEN** the current line is `check @images/diagram.svg`
- **THEN** `extract_path_from_line` SHALL return `"images/diagram.svg"`

#### Scenario: Bare filename
- **WHEN** the current line is `open @file.png`
- **THEN** `extract_path_from_line` SHALL return `"file.png"`

#### Scenario: Trailing punctuation stripped
- **WHEN** the current line is `see @file.png.`
- **THEN** `extract_path_from_line` SHALL return `"file.png"`

#### Scenario: Trailing comma stripped
- **WHEN** the current line is `@image.svg, and more`
- **THEN** `extract_path_from_line` SHALL return `"image.svg"`

### Requirement: Cursor-aware match selection
When multiple path references exist on a single line, the plugin SHALL select the one closest to the cursor column.

#### Scenario: Cursor near second match
- **WHEN** the line is `![](arch.svg) and ![](team.jpg)` and cursor is at column 30
- **THEN** SHALL return `"team.jpg"`

#### Scenario: Cursor near first match
- **WHEN** the line is `![](arch.svg) and ![](team.jpg)` and cursor is at column 5
- **THEN** SHALL return `"arch.svg"`

#### Scenario: Cursor inside match
- **WHEN** the cursor is positioned within the path text of a match
- **THEN** that match SHALL be selected (distance = 0)

#### Scenario: Tie-breaking
- **WHEN** the cursor is equidistant from two matches
- **THEN** the match appearing first on the line SHALL be selected

#### Scenario: col is nil (programmatic caller)
- **WHEN** `extract_path_from_line` is called with col = nil
- **THEN** SHALL return the first match on the line

### Requirement: Validate @-inside-markdown
The plugin SHALL detect and reject `@` at the start of a path extracted from markdown syntax.

#### Scenario: @ path in markdown image
- **WHEN** the current line is `![img](@some/path.png)`
- **THEN** SHALL return nil and an error: `"Mimosa: '@' reference inside markdown syntax is not supported. Use ![img](some/path.png) or @some/path.png instead"`

#### Scenario: @ path in markdown link
- **WHEN** the current line is `[link](@some/file.pdf)`
- **THEN** SHALL return nil and the same error message

### Requirement: Extract path from visual selection
The plugin SHALL extract the selected text from a single-line visual selection.

#### Scenario: Single line selected
- **WHEN** the user visually selects `images/diagram.svg` on a single line
- **THEN** `extract_path_from_selection` SHALL return `"images/diagram.svg"`

#### Scenario: Multi-line selection
- **WHEN** the user selects text spanning multiple lines
- **THEN** `extract_path_from_selection` SHALL return nil and notify the user
