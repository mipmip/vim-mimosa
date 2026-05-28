local M = {}

function M.extract_path_from_line(line)
  local open = line:find("(", 1, true)
  if not open then
    return nil
  end
  local rest = line:sub(open + 1)
  local close = rest:find(")", 1, true)
  if not close then
    return nil
  end
  return rest:sub(1, close - 1)
end

function M.extract_path_from_selection()
  local line_start = vim.fn.line("'<")
  local line_end = vim.fn.line("'>")
  if line_start ~= line_end then
    vim.notify("Select one line containing a valid file path", vim.log.levels.WARN)
    return nil
  end

  local col_start = vim.fn.col("'<")
  local col_end = vim.fn.col("'>")
  local line = vim.fn.getline(line_start)

  if vim.o.selection == "inclusive" then
    return line:sub(col_start, col_end)
  else
    return line:sub(col_start, col_end - 1)
  end
end

return M
