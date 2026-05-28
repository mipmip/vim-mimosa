## ADDED Requirements

### Requirement: Create new file via `:MimosaNew` command
The plugin SHALL provide a `:MimosaNew [ext] [path]` command that creates a new file reference, inserts the appropriate tag at the cursor, creates the file from template, and opens it in the configured handler.

#### Scenario: No arguments — full interactive flow
- **WHEN** the user runs `:MimosaNew` with no arguments
- **THEN** SHALL show `vim.ui.select` with sorted extension handler keys
- **AND** after selection, SHALL prompt with `vim.ui.input` for file path
- **AND** SHALL insert tag, create file, and open handler

#### Scenario: Extension argument only
- **WHEN** the user runs `:MimosaNew svg`
- **THEN** SHALL skip the picker and prompt for file path directly
- **AND** SHALL insert tag, create file, and open handler

#### Scenario: Both arguments
- **WHEN** the user runs `:MimosaNew svg images/diagram`
- **THEN** SHALL skip picker and prompt, insert tag for `images/diagram.svg`, create file, and open handler

#### Scenario: Invalid extension
- **WHEN** the user runs `:MimosaNew xyz` and `xyz` has no configured handler
- **THEN** SHALL show an error via `vim.notify`: `"Mimosa: no handler configured for 'xyz'"`

### Requirement: Filetype-aware tag insertion
The plugin SHALL insert the file reference tag in a format appropriate to the buffer's filetype.

#### Scenario: Markdown buffer
- **WHEN** `vim.bo.filetype` is `markdown` or `quarto`
- **THEN** SHALL insert `![](path)`

#### Scenario: HTML buffer
- **WHEN** `vim.bo.filetype` is `html`
- **THEN** SHALL insert `<img src="path">`

#### Scenario: Unknown filetype
- **WHEN** `vim.bo.filetype` is empty or unrecognized
- **THEN** SHALL fall back to markdown format `![](path)`

### Requirement: Tag insertion at cursor position
The plugin SHALL insert the tag at the current cursor position.

#### Scenario: Cursor in middle of line
- **WHEN** the cursor is in the middle of a line of text
- **THEN** SHALL insert the tag at the cursor column

### Requirement: Extension appending
The plugin SHALL append the selected extension to the path if not already present.

#### Scenario: Path without extension
- **WHEN** the user enters `images/diagram` and extension is `svg`
- **THEN** the resolved path SHALL be `images/diagram.svg`

#### Scenario: Path already has correct extension
- **WHEN** the user enters `images/diagram.svg` and extension is `svg`
- **THEN** the resolved path SHALL be `images/diagram.svg` (no double extension)

### Requirement: Path handling for new files
The plugin SHALL handle relative and absolute paths differently when creating new files.

#### Scenario: Relative path
- **WHEN** the user enters a relative path (no leading `/`)
- **THEN** SHALL resolve relative to the current buffer's directory
- **AND** SHALL create parent directories with `mkdir -p`

#### Scenario: Absolute path with existing parent
- **WHEN** the user enters an absolute path and the parent directory exists
- **THEN** SHALL use the path as-is

#### Scenario: Absolute path with missing parent
- **WHEN** the user enters an absolute path and the parent directory does not exist
- **THEN** SHALL show an error via `vim.notify`: `"Mimosa: directory does not exist: <dir>"`
- **AND** SHALL NOT create the directory or insert a tag

### Requirement: User cancellation
The plugin SHALL handle user cancellation at any prompt step.

#### Scenario: Cancel at extension picker
- **WHEN** the user cancels `vim.ui.select` (e.g. pressing `<Esc>`)
- **THEN** SHALL do nothing (no error, no insertion)

#### Scenario: Cancel at path prompt
- **WHEN** the user cancels `vim.ui.input`
- **THEN** SHALL do nothing

#### Scenario: Empty path input
- **WHEN** the user submits an empty string at the path prompt
- **THEN** SHALL do nothing
