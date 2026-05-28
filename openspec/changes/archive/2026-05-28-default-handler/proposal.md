# Allow More File Formats via Default Handler

**Status**: proposed
**Schema**: spec-driven
**Bean**: vim-mimosa-c26h

## Problem

Mimosa only opens files with explicitly configured extensions (svg, png, jpg, gif). Any other file reference (docx, pdf, mp4, ods, etc.) is silently ignored.

## Solution

Add a `default_handler` config option, auto-detected as `xdg-open` (Linux), `open` (macOS), or `start` (Windows). When no explicit handler exists for an extension, fall back to `default_handler`. Suppress the "no template" warning when using the fallback. Only open files that already exist when falling back (no empty file creation).

`:MimosaNew` is unchanged — its picker stays limited to explicitly configured handlers.

## Scope

### In scope
- `default_handler` config with platform auto-detection
- `get_extension_handler` falls back to `default_handler`
- Suppress "no template" warning for unconfigured extensions
- Only open existing files when using fallback (no touch/create)

### Out of scope
- New templates for additional formats
- Changes to `:MimosaNew`
- User-configurable "no template" warning behavior
