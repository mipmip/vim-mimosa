# vim-mimosa


<p align="center">
  <img src="mimosa-logo.png" width="200" alt="mimosa logo">
</p>

This plugin enables you to quickly create or edit a file in an external application. If the file does not exist it can be created using templates.

## Why I made this.

I make presentations in markdown (quarto with revealjs). Markdown is perfect
for quick braindumps but sometimes I just want an empty canvas to tell my story
visually. Placing my cursor on e.g. `![](images/about-mimosa.svg)` and running
`:Mimosa` will open inkscape with this file. If it does not exist it offers me
a list with svg-templates.

The same can be configured for any other extension in combination with any
other application.

## Features

- opens file under the cursor in external application
- creates file from template if not existing yet
- makes parent directories if they do not exist
- extendable with new extensions

## Limitations

- currently only able to detect file paths inside `![]()` markdown image tags.

## Demo

https://github.com/user-attachments/assets/b5684adb-b5cb-474f-9663-e74d044f4a03

## Todo

- make small video
- currently only one extension template is supported

## Filetypes

Any markdown image filetype can be configured. By default `svg`,`png`, `jpg`
and `gif` are preconfigured.

Show me a ![](images/typical.jpg).

## Installation

Install with a vim-plugin manager, with Plug:

```
Plug 'mipmip/vim-mimosa' ,  { 'branch': 'main' }
```

With Lazy:

```lua
{
    'mipmip/vim-mimosa',
}
```

## Configuration

### Default

Mimosa should work out of the box with the configuration below:

```lua
require("mimosa").setup({
  -- path where your templates live
  -- the templates directory has subdirectories per supported extension
  -- default path is in plugin directory
  templates_path = "<plugin_root>/mimosa_templates/",

  -- every extension should have an application configured
  extension_handlers = {
    svg = "inkscape",
    png = "gimp",
    jpg = "gimp",
    gif = "gimp",
  },
})
```

### Custom template path

Copy the template dir from the plugin to a directory e.g. in your home dir.

```lua
require("mimosa").setup({
  templates_path = vim.fn.expand("$HOME") .. "/my_mimosa_templates/",
})
```



**Why the name mimosa?** Well I like this beautifull tree and some smart AI thought it was an acronym, **M**edia **I**n **M**arkdown **O**pener for **S**pecialized **A**pplications. I didn't want to dissapoint it.
