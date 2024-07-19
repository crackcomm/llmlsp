-- Credit: copied from sg.nvim
-- TODO: move to lua/colab
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

--- Get the current selection
--- Resets the visual selection
---@return table
utils.get_selection = function()
  utils.execute_keystrokes("<ESC>")

  local start_line = vim.fn.getpos("'<")[2] - 1
  local end_line = vim.fn.getpos("'>")[2]

  return { start_line = start_line, end_line = end_line }
end

return utils
