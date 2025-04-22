-- Credit: some functions were copied from sg.nvim
local utils = {}

utils.once = function(f)
  local value, called = nil, false
  return function(...)
    if not called then
      value = f(...)
      called = true
    end

    return value
  end
end

--- Format some code based on the filetype
---@param bufnr number
---@param code string|string[]
---@return table
utils.format_code = function(bufnr, code)
  return vim.tbl_flatten({ string.format("```%s", vim.bo[bufnr].filetype), code, "```" })
end

utils.indent_code = function(lines, indent)
  local indented = {}
  for _, line in ipairs(lines) do
    table.insert(indented, string.rep(" ", indent) .. line)
  end
  return indented
end

utils.find_indentation = function(lines)
  -- find indentation of first non-empty line
  local indent = 0
  for _, line in ipairs(lines) do
    if line:match("%S") then
      indent = line:match("^%s*"):len()
      break
    end
  end
  return indent
end

utils.execute_keystrokes = function(keys)
  vim.cmd(string.format("normal! %s", vim.api.nvim_replace_termcodes(keys, true, false, true)))
end

-- COMPAT(0.10.0)
utils.joinpath = vim.fs.joinpath or function(...)
  return (table.concat({ ... }, "/"):gsub("//+", "/"))
end

-- From https://gist.github.com/jrus/3197011
utils.uuid = function()
  local template = "xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx"
  return string.gsub(template, "[xy]", function(c)
    local v = (c == "x") and math.random(0, 0xf) or math.random(8, 0xb)
    return string.format("%x", v)
  end)
end

utils.tbl_trim = function(tbl)
  return vim.split(vim.trim(table.concat(tbl, "\n")), "\n")
end

--- Get the current selection.
--- Resets the visual selection.
---@return {start_line: number, start_char: number, end_line: number, end_char: number} The selection details.
utils.get_selection = function()
  utils.execute_keystrokes("<ESC>")

  local start_pos = vim.fn.getpos("'<")
  local end_pos = vim.fn.getpos("'>")

  local start_line = start_pos[2] - 1 -- Convert to 0-based indexing for lines.
  local start_char = start_pos[3] - 1 -- Convert to 0-based indexing for characters.
  local end_line = end_pos[2]
  local end_char = end_pos[3]

  return { start_line = start_line, start_char = start_char, end_line = end_line, end_char = end_char }
end
return utils
