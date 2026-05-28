local config = require("mimosa.config")
local template = require("mimosa.template")
local parse = require("mimosa.parse")
local insert = require("mimosa.insert")

local M = {}

function M.setup(opts)
  config.setup(opts)

  vim.api.nvim_create_user_command("Mimosa", function()
    local line = vim.fn.getline(".")
    local col = vim.fn.col(".")
    local path, err = parse.extract_path_from_line(line, col)
    if err then
      vim.notify(err, vim.log.levels.ERROR)
      return
    end
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

  vim.api.nvim_create_user_command("MimosaNew", function(opts)
    local args = vim.split(opts.args, "%s+", { trimempty = true })
    local ext_arg = args[1]
    local path_arg = args[2]

    local function do_with_ext(ext)
      if not ext then return end
      if not config.values.extension_handlers[ext] then
        vim.notify("Mimosa: no handler configured for '" .. ext .. "'", vim.log.levels.ERROR)
        return
      end

      local function do_with_path(input)
        if not input or input == "" then return end
        local path, err = insert.resolve_path(input, ext)
        if err then
          vim.notify(err, vim.log.levels.ERROR)
          return
        end
        if not path then return end
        local tag = insert.format_tag(path, vim.bo.filetype)
        insert.insert_tag_at_cursor(tag)
        template.open_template(path)
      end

      if path_arg then
        do_with_path(path_arg)
      else
        vim.ui.input({ prompt = "Mimosa: file path (e.g. images/diagram): " }, do_with_path)
      end
    end

    if ext_arg then
      do_with_ext(ext_arg)
    else
      local exts = vim.tbl_keys(config.values.extension_handlers)
      table.sort(exts)
      vim.ui.select(exts, { prompt = "Mimosa: select filetype" }, do_with_ext)
    end
  end, { nargs = "*" })
end

return M
