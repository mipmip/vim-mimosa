local M = {}

local function get_plugin_root()
  local source = debug.getinfo(1, "S").source:sub(2)
  -- source is <plugin_root>/lua/mimosa/config.lua, go up 3 levels
  return vim.fn.fnamemodify(source, ":h:h:h")
end

local function detect_opener()
  if vim.fn.has("mac") == 1 then return "open" end
  if vim.fn.has("win32") == 1 then return "start" end
  return "xdg-open"
end

local defaults = {
  templates_path = get_plugin_root() .. "/mimosa_templates/",
  default_handler = detect_opener(),
  extension_handlers = {
    svg = "inkscape",
    png = "gimp",
    jpg = "gimp",
    gif = "gimp",
  },
}

M.values = vim.deepcopy(defaults)

function M.setup(opts)
  opts = opts or {}
  M.values = vim.tbl_deep_extend("force", vim.deepcopy(defaults), opts)
  -- tbl_deep_extend merges tables, so an explicit empty table won't clear defaults.
  -- If the caller explicitly passed extension_handlers, use it as-is.
  if opts.extension_handlers then
    M.values.extension_handlers = vim.deepcopy(opts.extension_handlers)
  end
end

return M
