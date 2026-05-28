local config = require("mimosa.config")

local M = {}

function M.get_extension_handler(ext)
  return config.values.extension_handlers[ext]
      or config.values.default_handler
end

function M.get_template_file(ext, callback)
  local pattern = config.values.templates_path .. ext .. "/*." .. ext
  local files = vim.fn.glob(pattern, false, true)
  table.sort(files)
  if #files == 0 then
    if config.values.extension_handlers[ext] then
      vim.notify("Mimosa: no template file found for " .. ext, vim.log.levels.WARN)
    end
    callback(nil)
    return
  end
  if #files == 1 then
    callback(files[1])
    return
  end
  local names = {}
  for _, f in ipairs(files) do
    names[#names + 1] = vim.fn.fnamemodify(f, ":t")
  end
  vim.ui.select(names, { prompt = "Mimosa: select template" }, function(_, idx)
    if idx then
      callback(files[idx])
    else
      callback(nil)
    end
  end)
end

function M.open_template(path)
  local root_dir = vim.fn.expand("%:h")
  local file_path = root_dir .. "/" .. path
  local file_dir = vim.fn.fnamemodify(file_path, ":h")
  local file_ext = vim.fn.fnamemodify(path, ":e"):lower()

  if vim.fn.filereadable(file_path) == 0 then
    if vim.fn.isdirectory(file_dir) == 0 then
      vim.fn.mkdir(file_dir, "p")
    end

    M.get_template_file(file_ext, function(tpl_file)
      if tpl_file then
        vim.fn.system({ "cp", tpl_file, file_path })
      end

      if vim.fn.filereadable(file_path) == 1 then
        local handler = M.get_extension_handler(file_ext)
        if handler then
          vim.fn.system({ handler, file_path })
        end
      end
    end)
  else
    local handler = M.get_extension_handler(file_ext)
    if handler then
      vim.fn.system({ handler, file_path })
    end
  end
end

return M
