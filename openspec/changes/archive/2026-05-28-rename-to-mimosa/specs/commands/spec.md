## MODIFIED Requirements

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

## RENAMED Requirements

### Requirement: Nomisa command parses current line and opens template
FROM: Nomisa command parses current line and opens template
TO: Mimosa command parses current line and opens template

### Requirement: NomisaVisSel command uses visual selection as path
FROM: NomisaVisSel command uses visual selection as path
TO: MimosaVisSel command uses visual selection as path
