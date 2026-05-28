local plugin_root = vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":h:h")
vim.opt.runtimepath:prepend(plugin_root)

-- Prevent plugin/mimosa.lua from auto-loading with real handlers
-- Tests require modules directly and configure their own safe handlers
vim.g.mimosa_disable_autosetup = true
