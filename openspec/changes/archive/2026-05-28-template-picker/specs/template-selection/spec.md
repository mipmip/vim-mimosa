## CHANGED Requirements

### Requirement: Template selection with picker
The plugin SHALL show a `vim.ui.select` picker when multiple templates exist for an extension, and use the selected template. When only one template exists, it SHALL be used directly without prompting.

#### Scenario: Single template
- **WHEN** `get_template_file("svg")` is called and one SVG template exists
- **THEN** SHALL return that template without prompting

#### Scenario: Multiple templates
- **WHEN** `get_template_file("svg")` is called and multiple SVG templates exist
- **THEN** SHALL show `vim.ui.select` with template filenames
- **AND** SHALL return the selected template

#### Scenario: User cancels picker
- **WHEN** the user cancels `vim.ui.select` at the template picker
- **THEN** SHALL not create the file and not launch a handler

#### Scenario: No templates
- **WHEN** `get_template_file("docx")` is called and no templates exist
- **THEN** SHALL return nil (unchanged behavior)

## ADDED Requirements

### Requirement: Descriptive template filenames
Templates SHALL use descriptive filenames that serve as labels in the picker.

#### Scenario: SVG templates
- **WHEN** the plugin ships default SVG templates
- **THEN** SHALL include `empty-canvas.svg` and `wireframe-960x700.svg`
