-- Credit: based on sg.nvim cody commands

---@tag colab.chat.lua-commands

local tasks = require("colab.client.tasks")
local util = require("colab.utils")

local CodyBase = require("colab.chat.layout.base")
local CodySplit = require("colab.chat.layout.split")
local FloatPrompt = require("colab.chat.layout.float_prompt")
local Message = require("colab.chat.message")
local Speaker = require("colab.chat.types").Speaker
local State = require("colab.chat.state")

local commands = {}

--- Ask LLM a question, without any selection
---@param message string[]
commands.ask = function(message)
  local layout = CodySplit.init({})

  local contents = vim.tbl_flatten(message)
  layout:request_user_message(contents)
end

--- Ask LLM about the selected code
---@param bufnr number
---@param start_row number
---@param end_row number
---@param message string
commands.ask_range = function(bufnr, start_row, end_row, message)
  local selection = vim.api.nvim_buf_get_lines(bufnr, start_row, end_row, false)
  local layout = CodySplit.init({})

  local contents = vim.tbl_flatten({
    message,
    "",
    util.format_code(bufnr, selection),
  })

  layout:request_user_message(contents)
end

--- Ask LLM to perform a task on the selected code
---@param bufnr number
---@param start_line number
---@param end_line number
commands.float = function(bufnr, start_line, end_line)
  local callback = function(text)
    vim.api.nvim_buf_set_lines(bufnr, start_line, end_line, false, text)
  end

  local on_submit = function(_, value)
    local text = table.concat(value, "\n")
    tasks.do_task(bufnr, start_line, end_line, text, callback)
  end

  local layout = FloatPrompt.init({ on_submit = on_submit })

  layout:show()
end

--- Start a new CodyChat
---@param opts { reset: boolean }?
---@return CodyLayoutSplit
commands.chat = function(opts)
  local state = State.last()
  -- TODO: Config for this :)
  opts = vim.tbl_extend("force", { state = state }, opts or {})
  local layout = CodySplit.init(opts)
  layout:show()

  return layout
end

--- Open a selection to get an existing LLM conversation
commands.history = function()
  -- remove empty states
  local states = State.clean_history()

  vim.ui.select(states, {
    prompt = "LLM History: ",
    format_item = function(state)
      local req = string.sub(state:last_request().message.msg[1], 0, 20)
      local resp = string.sub(state:last_response().message.msg[1], 0, 20)
      return string.format("%s..%s (%d msgs)", req, resp, #state.messages)
    end,
  }, function(state)
    if state ~= nil then
      vim.schedule(function()
        local layout = CodySplit.init({ state = state })
        layout:show()
      end)
    end
  end)
end

--- Add context to an existing state
---@param start_line any
---@param end_line any
---@param state CodyState?
commands.add_context = function(bufnr, start_line, end_line, state)
  local selection = vim.api.nvim_buf_get_lines(bufnr, start_line, end_line, false)

  local content = vim.tbl_flatten({
    "Some additional context is:",
    util.format_code(bufnr, selection),
  })

  -- TODO: We should be re-rendering when we see this happen
  if not state then
    state = State.last()
  end
  ---@diagnostic disable-next-line: need-check-nil
  state:append(Message.init(Speaker.user, content, {}))
end

commands.toggle = function()
  CodySplit:toggle()
end

--- Focus the currently active history window.
---
--- Can be set to a keymap by:
--- <code=lua>
---   vim.keymap.set('n', '<leader>ch', function()
---     require("colab.chat.commands").focus_history()
---   end)
--- </code>
commands.focus_history = function()
  local active = CodyBase:get_active()
  if not active then
    return
  end

  local win = active.history.win
  if not vim.api.nvim_win_is_valid(win) then
    return
  end

  return vim.api.nvim_set_current_win(win)
end

--- Focus the currently active prompt.
---
--- Can be set to a keymap by:
--- <code=lua>
---   vim.keymap.set('n', '<leader>cp', function()
---     require("colab.chat.commands").focus_prompt()
---   end)
--- </code>
commands.focus_prompt = function()
  local active = CodyBase:get_active()
  if not active then
    return
  end

  if not active.prompt then
    return
  end

  local win = active.prompt.win
  if not vim.api.nvim_win_is_valid(win) then
    return
  end

  -- ??
  -- vim.cmd [[startinsert]]

  return vim.api.nvim_set_current_win(win)
end

commands.add_contents = function(bufnr, start_line, end_line)
  local active = CodySplit:get_active_or_create()
  active:show()
  active:append_text(bufnr, start_line, end_line)
end

return commands
