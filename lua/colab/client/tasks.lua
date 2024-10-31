local util = require("colab.utils")

local tasks = {}

--- Ask an LLM to perform a task on the selected code.
---@param bufnr number
---@param start_line number
---@param end_line number
---@param message string
tasks.do_task = function(bufnr, start_line, end_line, message, callback)
  local selection = vim.api.nvim_buf_get_lines(bufnr, start_line, end_line, false)

  local formatted = util.format_code(bufnr, selection)

  local prompt = message
  prompt = prompt .. "\nReply only with code, nothing else. Enclose it in a markdown style block.\n"
  prompt = prompt .. table.concat(formatted, "\n")

  require("colab.client").execute.code_question(prompt, function(msg)
    if msg == nil then
      return
    end

    local text = vim.split(msg.text, "\n")

    -- wait until we have ``` in last line
    -- and text length is greater than 1
    if text[#text] ~= "```" or #text <= 1 then
      return
    end

    table.remove(text)
    table.remove(text, 1)

    local indent = util.find_indentation(selection)
    callback(util.indent_code(text, indent))
  end)
end

return tasks
