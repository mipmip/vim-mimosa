## ADDED Requirements

### Requirement: Plugin provides default configuration
The plugin SHALL provide default configuration with `templates_path` auto-detected from the plugin's install location and `extension_handlers` mapping svg to inkscape, and png/jpg/gif to gimp.

#### Scenario: Default templates path
- **WHEN** the plugin loads without user configuration
- **THEN** `templates_path` SHALL be set to `<plugin_root>/mimosa_templates/`

#### Scenario: Default extension handlers
- **WHEN** the plugin loads without user configuration
- **THEN** `extension_handlers` SHALL contain `{svg = "inkscape", png = "gimp", jpg = "gimp", gif = "gimp"}`

### Requirement: Default handler for unconfigured extensions
The plugin SHALL provide a `default_handler` config option, auto-detected based on platform: `xdg-open` (Linux), `open` (macOS), `start` (Windows).

#### Scenario: Default on Linux
- **WHEN** the plugin loads on Linux without user configuration
- **THEN** `default_handler` SHALL be `"xdg-open"`

#### Scenario: User overrides default handler
- **WHEN** user calls `setup({ default_handler = "my-opener" })`
- **THEN** `default_handler` SHALL be `"my-opener"`

#### Scenario: Fallback for unconfigured extension
- **WHEN** `get_extension_handler` is called with an extension not in `extension_handlers`
- **THEN** SHALL return `default_handler`

### Requirement: User can override configuration via setup()
The plugin SHALL accept a `setup(opts)` call that deep-merges user options over defaults.

#### Scenario: User adds a new extension handler
- **WHEN** user calls `setup({ extension_handlers = { kra = "krita" } })`
- **THEN** the config SHALL contain `kra = "krita"` AND retain default handlers (svg, png, jpg, gif)

#### Scenario: User overrides an existing handler
- **WHEN** user calls `setup({ extension_handlers = { svg = "firefox" } })`
- **THEN** `extension_handlers.svg` SHALL be `"firefox"`

#### Scenario: User overrides templates path
- **WHEN** user calls `setup({ templates_path = "/custom/path/" })`
- **THEN** `templates_path` SHALL be `"/custom/path/"`

### Requirement: Setup is idempotent
Calling `setup()` multiple times SHALL update the configuration to the latest call's values.

#### Scenario: Calling setup twice
- **WHEN** user calls `setup({ extension_handlers = { svg = "firefox" } })` then `setup({ extension_handlers = { svg = "chromium" } })`
- **THEN** `extension_handlers.svg` SHALL be `"chromium"`
