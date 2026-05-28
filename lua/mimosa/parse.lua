local M = {}

function M.extract_markdown_paths(line)
  local matches = {}
  local pos = 1
  while pos <= #line do
    local bracket_close = line:find("%]%(", pos)
    if not bracket_close then break end
    local paren_open = bracket_close + 1
    local paren_start = paren_open + 1
    local paren_close = line:find(")", paren_start, true)
    if not paren_close then break end
    local path = line:sub(paren_start, paren_close - 1)
    if #path > 0 then
      matches[#matches + 1] = {
        path = path,
        start = paren_start,
        fin = paren_close - 1,
        type = "markdown",
      }
    end
    pos = paren_close + 1
  end
  return matches
end

function M.extract_html_img_paths(line)
  local matches = {}
  local pos = 1
  while pos <= #line do
    -- Find <img with a word boundary (whitespace or > must follow attributes)
    local img_start = line:find("<img%s", pos)
    if not img_start then break end
    local tag_end = line:find(">", img_start)
    if not tag_end then break end
    local tag_content = line:sub(img_start, tag_end)
    -- Try double-quoted src
    local src = tag_content:match('src%s*=%s*"([^"]*)"')
    if not src then
      -- Try single-quoted src
      src = tag_content:match("src%s*=%s*'([^']*)'")
    end
    if not src then
      -- Try unquoted src (terminated by space, >, or /)
      src = tag_content:match("src%s*=%s*([^%s>/'\"]+)")
    end
    if src and #src > 0 then
      -- Find the position of src value within the original line
      local src_pos = line:find(src, img_start, true)
      if src_pos then
        matches[#matches + 1] = {
          path = src,
          start = src_pos,
          fin = src_pos + #src - 1,
          type = "html_img",
        }
      end
    end
    pos = tag_end + 1
  end
  return matches
end

function M.extract_at_paths(line)
  local matches = {}
  local pos = 1
  while pos <= #line do
    local at_pos = line:find("@", pos, true)
    if not at_pos then break end
    -- Grab non-whitespace after @
    local raw = line:match("^(%S+)", at_pos + 1)
    if raw and #raw > 0 then
      -- Strip trailing punctuation
      local stripped = raw:gsub("[.,;:!%?)]+$", "")
      if #stripped > 0 then
        matches[#matches + 1] = {
          path = stripped,
          start = at_pos + 1,
          fin = at_pos + #stripped,
          type = "at_ref",
        }
      end
    end
    pos = at_pos + 1
  end
  return matches
end

function M.pick_closest(matches, col)
  if #matches == 0 then return nil end
  if col == nil then return matches[1] end

  local best = nil
  local best_dist = math.huge
  for _, m in ipairs(matches) do
    local dist
    if col >= m.start and col <= m.fin then
      dist = 0
    else
      dist = math.min(math.abs(col - m.start), math.abs(col - m.fin))
    end
    if dist < best_dist then
      best = m
      best_dist = dist
    end
    -- Ties: first on line wins (iteration order is left-to-right)
  end
  return best
end

local VALIDATION_ERROR = "Mimosa: '@' reference inside markdown syntax is not supported. Use ![img](some/path.png) or @some/path.png instead"

function M.validate(matches)
  for _, m in ipairs(matches) do
    if m.type == "markdown" and m.path:sub(1, 1) == "@" then
      return nil, VALIDATION_ERROR
    end
  end
  return matches, nil
end

function M.extract_path_from_line(line, col)
  local all_matches = {}

  local md = M.extract_markdown_paths(line)
  for _, m in ipairs(md) do all_matches[#all_matches + 1] = m end

  local html = M.extract_html_img_paths(line)
  for _, m in ipairs(html) do all_matches[#all_matches + 1] = m end

  local at = M.extract_at_paths(line)
  for _, m in ipairs(at) do all_matches[#all_matches + 1] = m end

  if #all_matches == 0 then return nil, nil end

  -- Sort by position for consistent ordering
  table.sort(all_matches, function(a, b) return a.start < b.start end)

  -- Validate before picking
  local validated, err = M.validate(all_matches)
  if not validated then return nil, err end

  local match = M.pick_closest(validated, col)
  if match then
    return match.path, nil
  end
  return nil, nil
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
