local config = require("mimosa.config")
local template = require("mimosa.template")
local parse = require("mimosa.parse")

local M = {}

function M.setup(opts)
  config.setup(opts)

  vim.api.nvim_create_user_command("Mimosa", function()
    local line = vim.fn.getline(".")
    local path = parse.extract_path_from_line(line)
    if path then
      template.open_template(path)
    end
  end, {})

  vim.api.nvim_create_user_command("MimosaVisSel", function()
    local path = parse.extract_path_from_selection()
    if path then
      template.open_template(path)
    end
  end, { range = true })
end

return M
