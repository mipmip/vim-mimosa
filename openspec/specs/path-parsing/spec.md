## ADDED Requirements

### Requirement: Extract path from markdown image link
The plugin SHALL extract the file path from a markdown image link on the current line, matching the pattern `![...](path)`.

#### Scenario: Standard markdown image link
- **WHEN** the current line is `![alt text](images/diagram.svg)`
- **THEN** `extract_path_from_line` SHALL return `"images/diagram.svg"`

#### Scenario: Empty alt text
- **WHEN** the current line is `![](images/diagram.svg)`
- **THEN** `extract_path_from_line` SHALL return `"images/diagram.svg"`

#### Scenario: Line with parentheses but no image syntax
- **WHEN** the current line is `some text (with parens)`
- **THEN** `extract_path_from_line` SHALL return `"with parens"` (matches existing VimL behavior of splitting on first `(` and `)`)

#### Scenario: No parentheses on line
- **WHEN** the current line is `just plain text`
- **THEN** `extract_path_from_line` SHALL return nil

### Requirement: Extract path from visual selection
The plugin SHALL extract the selected text from a single-line visual selection.

#### Scenario: Single line selected
- **WHEN** the user visually selects `images/diagram.svg` on a single line
- **THEN** `extract_path_from_selection` SHALL return `"images/diagram.svg"`

#### Scenario: Multi-line selection
- **WHEN** the user selects text spanning multiple lines
- **THEN** `extract_path_from_selection` SHALL return nil and notify the user
