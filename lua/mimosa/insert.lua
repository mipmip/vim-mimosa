local M = {}

function M.format_tag(path, filetype)
  filetype = filetype or ""
  if filetype == "html" then
    return '<img src="' .. path .. '">'
  end
  return "![](" .. path .. ")"
end

function M.insert_tag_at_cursor(tag)
  vim.api.nvim_put({ tag }, "c", false, true)
end

function M.resolve_path(input, ext)
  if not input or input == "" then
    return nil, nil
  end
  -- Append extension if not already present
  if not input:match("%." .. ext .. "$") then
    input = input .. "." .. ext
  end
  -- Validate absolute paths
  if input:sub(1, 1) == "/" then
    local parent = vim.fn.fnamemodify(input, ":h")
    if vim.fn.isdirectory(parent) == 0 then
      return nil, "Mimosa: directory does not exist: " .. parent
    end
  end
  return input, nil
end

return M
