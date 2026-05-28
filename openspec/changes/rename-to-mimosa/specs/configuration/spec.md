## MODIFIED Requirements

### Requirement: Plugin provides default configuration
The plugin SHALL provide default configuration with `templates_path` auto-detected from the plugin's install location and `extension_handlers` mapping svg to inkscape, and png/jpg/gif to gimp.

#### Scenario: Default templates path
- **WHEN** the plugin loads without user configuration
- **THEN** `templates_path` SHALL be set to `<plugin_root>/mimosa_templates/`

#### Scenario: Default extension handlers
- **WHEN** the plugin loads without user configuration
- **THEN** `extension_handlers` SHALL contain `{svg = "inkscape", png = "gimp", jpg = "gimp", gif = "gimp"}`
