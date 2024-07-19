local M = {}

M.setup = function(opts)
  opts = opts or {}

  local config = require("colab.config")
  for key, value in pairs(opts) do
    if config[key] ~= nil then
      config[key] = value
    end
  end

  require("colab.lsp").setup(config)
  require("colab.chat")
  require("colab.chat.keymaps").on_init()
end

return M
