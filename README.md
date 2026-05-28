# Nomisa - Vim/Neovim Plugin

This plugin enables you to quickly create or edit a file in an external explication. If the file does not exist they can be created using templates.

## Why I made this.

I make presentations in markdown (quarto with revealjs). Markdown is perfect
for quick braindumps but sometimes I just want an empty canvas to tell my story
visually. Placing my cursor on e.g. `![](images/about-nomisa.svg)` and running
`:Nomisa` will open inkscape with this file. If it does not exist is offers me
a list with svg-templates.

The same can be configured for any other extension in combination with any
other application.

## Features

- opens file under the cursor in external application
- creates file from template if not existing yet
- makes parent directories is they do not exist
- extendable with new extensions

## Limitations

- currently only able to detect file paths inside `![]()` markdown image tags.

## Demo

https://github.com/user-attachments/assets/b5684adb-b5cb-474f-9663-e74d044f4a03

## Todo

- make small video
- currenty only one extension template is supported
 
## Filetypes

Any markdown image filetype can be configured. By default `svg`,`png`, `jpg`
and `gif` are preconfigured.

Show me a ![](images/typical.jpg).

## Usage

## Installation

Install with a vim-plugin manager, with Plug:

```
Plug 'mipmip/vim-nomisa' ,  { 'branch': 'main' }
```

With Lazy:

```lualine
{
    'mipmip/vim-nomisa',
}
```

## Configuration

### Default

Nomisa should work out of the box with the configuration below:

```vim

" path where you templates live

" - the templates directory has subdirectories per supported extension
" - default path is in plugin directory
" - path should have an trailing slash

let g:nomisa_templates_path = s:plugin_path . '/nomisa_templates/'

let g:nomisa_extension_handlers = {}

" every extension should have an application configured. You can use complete paths as well.
let g:nomisa_extension_handlers.svg = 'inkscape'
let g:nomisa_extension_handlers.png = 'gimp'
let g:nomisa_extension_handlers.jpg = 'gimp'
let g:nomisa_extension_handlers.gif = 'gimp'
```

### Custom template path

Copy the template dir from the plugin to a directory e.g. in your home dir.

```vim
let g:nomisa_templates_path = $HOME . '/my_nomisa_templates/'
```


