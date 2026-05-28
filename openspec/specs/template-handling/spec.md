## ADDED Requirements

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

### Requirement: Look up extension handler
The plugin SHALL return the configured handler program for a given file extension, or nil if none is configured.

#### Scenario: Handler exists for extension
- **WHEN** `extension_handlers` contains `svg = "inkscape"`
- **THEN** `get_extension_handler("svg")` SHALL return `"inkscape"`

#### Scenario: No handler for extension
- **WHEN** extension is `"txt"` and no handler is configured for it
- **THEN** `get_extension_handler("txt")` SHALL return nil

### Requirement: Open template creates file from template if missing
When opening a path that does not exist, the plugin SHALL create parent directories and copy the matching template file to the target path.

#### Scenario: File does not exist, template available
- **WHEN** `open_template("images/diagram.svg")` is called and `images/diagram.svg` does not exist and a svg template is available
- **THEN** the plugin SHALL create the `images/` directory if needed AND copy the template to `images/diagram.svg`

#### Scenario: File does not exist, no template available
- **WHEN** `open_template("images/photo.webp")` is called and no webp template exists
- **THEN** the plugin SHALL NOT create the file

#### Scenario: File already exists
- **WHEN** `open_template("images/diagram.svg")` is called and `images/diagram.svg` already exists
- **THEN** the plugin SHALL NOT overwrite the existing file

### Requirement: Open template launches handler for existing files
After ensuring the file exists, the plugin SHALL launch the configured external handler if one is set for the file's extension.

#### Scenario: Handler configured
- **WHEN** the file exists and a handler is configured for its extension
- **THEN** the plugin SHALL call the handler with the file path (shell-escaped)

#### Scenario: No handler configured
- **WHEN** the file exists but no handler is configured for its extension
- **THEN** the plugin SHALL do nothing (no error)

### Requirement: Paths resolve relative to current buffer directory
All paths passed to `open_template` SHALL be resolved relative to the directory of the current buffer (`vim.fn.expand("%:h")`).

#### Scenario: Relative path resolution
- **WHEN** current buffer is `/home/user/notes/readme.md` and path is `images/fig.svg`
- **THEN** the resolved path SHALL be `/home/user/notes/images/fig.svg`
