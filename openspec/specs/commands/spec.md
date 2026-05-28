## Requirements

### Requirement: Mimosa command parses current line and opens template
The `:Mimosa` command SHALL extract a path from the current line and call `open_template` with it.

#### Scenario: Line contains markdown image link
- **WHEN** user runs `:Mimosa` on a line containing `![](images/fig.svg)`
- **THEN** the plugin SHALL call `open_template("images/fig.svg")`

#### Scenario: Line contains no parseable path
- **WHEN** user runs `:Mimosa` on a line with no parentheses
- **THEN** the plugin SHALL do nothing (no error)

### Requirement: MimosaVisSel command uses visual selection as path
The `:MimosaVisSel` command SHALL extract the visual selection and call `open_template` with it.

#### Scenario: Valid single-line selection
- **WHEN** user visually selects `images/fig.svg` and runs `:MimosaVisSel`
- **THEN** the plugin SHALL call `open_template("images/fig.svg")`

#### Scenario: Multi-line selection
- **WHEN** user selects multiple lines and runs `:MimosaVisSel`
- **THEN** the plugin SHALL notify the user to select a single line containing a valid file path

### Requirement: MimosaNew command creates new file references
The `:MimosaNew [ext] [path]` command SHALL create a new file reference, insert the appropriate tag at the cursor, create the file from template, and open it in the configured handler.

#### Scenario: No arguments — full interactive flow
- **WHEN** the user runs `:MimosaNew` with no arguments
- **THEN** SHALL show `vim.ui.select` with sorted extension handler keys
- **AND** after selection, SHALL prompt with `vim.ui.input` for file path
- **AND** SHALL insert tag, create file, and open handler

#### Scenario: Extension argument only
- **WHEN** the user runs `:MimosaNew svg`
- **THEN** SHALL skip the picker and prompt for file path directly

#### Scenario: Both arguments
- **WHEN** the user runs `:MimosaNew svg images/diagram`
- **THEN** SHALL skip picker and prompt, insert tag for `images/diagram.svg`, create file, and open handler

#### Scenario: Invalid extension
- **WHEN** the user runs `:MimosaNew xyz` and `xyz` has no configured handler
- **THEN** SHALL show an error: `"Mimosa: no handler configured for 'xyz'"`

#### Scenario: Filetype-aware tag insertion
- **WHEN** buffer filetype is `markdown` or `quarto`
- **THEN** SHALL insert `![](path)`
- **WHEN** buffer filetype is `html`
- **THEN** SHALL insert `<img src="path">`
- **WHEN** buffer filetype is unknown
- **THEN** SHALL fall back to markdown format

#### Scenario: User cancellation
- **WHEN** the user cancels at any prompt step (picker or input)
- **THEN** SHALL do nothing (no error, no insertion)
