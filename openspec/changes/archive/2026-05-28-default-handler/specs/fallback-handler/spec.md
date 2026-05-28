## ADDED Requirements

### Requirement: Default handler for unconfigured extensions
The plugin SHALL fall back to a platform-detected default handler when no explicit handler is configured for a file extension.

#### Scenario: Open docx on Linux
- **WHEN** `:Mimosa` is run on `![](report.docx)` and no handler is configured for `docx`
- **THEN** SHALL open the file with `xdg-open`

#### Scenario: User overrides default handler
- **WHEN** user sets `default_handler = "my-opener"` in setup
- **THEN** SHALL use `"my-opener"` as the fallback

#### Scenario: File does not exist and no template
- **WHEN** `:Mimosa` is run on a reference to a non-existent `.docx` file
- **THEN** SHALL not create the file and not launch a handler

## CHANGED Requirements

### Requirement: Suppress template warning for unconfigured extensions
The plugin SHALL only warn about missing templates when the extension has an explicit handler configured.

#### Scenario: No template for docx (fallback handler)
- **WHEN** `get_template_file("docx")` is called and docx has no explicit handler
- **THEN** SHALL return nil without a warning

#### Scenario: No template for svg (explicit handler)
- **WHEN** `get_template_file("svg")` is called and svg has an explicit handler but no template
- **THEN** SHALL still warn "no template file found for svg"
