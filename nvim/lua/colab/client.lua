local log = require("colab.log")

local M = {}

M.get_client = function()
  for _, client in ipairs(vim.lsp.get_active_clients()) do
    if client.name == "llmlsp" then
      return client
    end
  end
  return nil
end

M.request = function(...)
  local client = M.get_client()
  if client == nil then
    log.error("LLM LSP Client not registered")
    return
  end
  client.rpc.request(...)
end

return M
