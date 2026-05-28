## MODIFIED Requirements

### Requirement: Find template file for extension
The plugin SHALL look up template files in `<templates_path>/<ext>/` matching `*.<ext>`.

#### Scenario: Single template exists
- **WHEN** `mimosa_templates/svg/` contains exactly one `.svg` file
- **THEN** `get_template_file("svg")` SHALL return the path to that file

#### Scenario: Multiple templates exist
- **WHEN** `mimosa_templates/svg/` contains multiple `.svg` files
- **THEN** `get_template_file("svg")` SHALL return the first file found

#### Scenario: No template exists
- **WHEN** `mimosa_templates/svg/` is empty or does not exist
- **THEN** `get_template_file("svg")` SHALL return nil and notify the user
