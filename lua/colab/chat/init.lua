---@tag colab.chat

---@brief [[
--- Default commands for interacting with chat
---@brief ]]

---@config { ["module"] = "colab.chat" }

local chat_commands = require("colab.chat.commands")

---@command :ColabAsk [[
--- Ask a question about the current selection.
---
--- Use from visual mode to pass the current selection
---@command ]]
vim.api.nvim_create_user_command("ColabAsk", function(command)
  if command.range == 0 then
    chat_commands.ask(command.args)
  else
    local bufnr = vim.api.nvim_get_current_buf()
    chat_commands.ask_range(bufnr, command.line1 - 1, command.line2, command.args)
  end
end, { range = 2, nargs = 1 })

---@command :Chat{!} {title} [[
--- State a new cody chat, with an optional {title}
---
--- If {!} is passed, will reset the chat and start a new chat conversation.
---@command ]]
vim.api.nvim_create_user_command("ColabChat", function(command)
  local name = nil
  if not vim.tbl_isempty(command.fargs) then
    name = table.concat(command.fargs, " ")
  end

  chat_commands.chat({ name = name, reset = command.bang })
end, { nargs = "*", bang = true })

---@command :ColabToggle [[
--- Toggles the current Chat window.
---@command ]]
vim.api.nvim_create_user_command("ColabToggle", function(_)
  chat_commands.toggle()
end, {})
