## ADDED Requirements

### Requirement: Nomisa command parses current line and opens template
The `:Nomisa` command SHALL extract a path from the current line and call `open_template` with it.

#### Scenario: Line contains markdown image link
- **WHEN** user runs `:Nomisa` on a line containing `![](images/fig.svg)`
- **THEN** the plugin SHALL call `open_template("images/fig.svg")`

#### Scenario: Line contains no parseable path
- **WHEN** user runs `:Nomisa` on a line with no parentheses
- **THEN** the plugin SHALL do nothing (no error)

### Requirement: NomisaVisSel command uses visual selection as path
The `:NomisaVisSel` command SHALL extract the visual selection and call `open_template` with it.

#### Scenario: Valid single-line selection
- **WHEN** user visually selects `images/fig.svg` and runs `:NomisaVisSel`
- **THEN** the plugin SHALL call `open_template("images/fig.svg")`

#### Scenario: Multi-line selection
- **WHEN** user selects multiple lines and runs `:NomisaVisSel`
- **THEN** the plugin SHALL notify the user to select a single line containing a valid file path
