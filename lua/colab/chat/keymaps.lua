local chat_commands = require("colab.chat.commands")
local utils = require("colab.utils")

local M = {}

function M.on_attach(_, bufnr)
  vim.keymap.set("v", "<leader>cf", function()
    local sel = utils.get_selection()
    chat_commands.float(bufnr, sel.start_line, sel.end_line)
  end, { buffer = bufnr, desc = "LLMLSP: [C]omplete [F]ragment" })

  vim.keymap.set("v", "<leader>af", function()
    local sel = utils.get_selection()
    chat_commands.add_contents(bufnr, sel.start_line, sel.end_line)
  end, { buffer = bufnr, desc = "LLMLSP: [A]ppend [F]ragment" })
end

function M.on_init()
  vim.keymap.set("n", "<leader>cc", function()
    chat_commands.toggle()
  end, { desc = "LLMLSP: [C]hat [C]ommands" })

  vim.keymap.set("n", "<leader>ch", function()
    chat_commands.history()
  end, { desc = "LLMLSP: [C]hat [H]istory" })
end

return M
