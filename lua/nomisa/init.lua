local config = require("nomisa.config")
local template = require("nomisa.template")
local parse = require("nomisa.parse")

local M = {}

function M.setup(opts)
  config.setup(opts)

  vim.api.nvim_create_user_command("Nomisa", function()
    local line = vim.fn.getline(".")
    local path = parse.extract_path_from_line(line)
    if path then
      template.open_template(path)
    end
  end, {})

  vim.api.nvim_create_user_command("NomisaVisSel", function()
    local path = parse.extract_path_from_selection()
    if path then
      template.open_template(path)
    end
  end, { range = true })
end

return M
