-- Credit: based on sg.nvim cody rpc

local client = require("colab.client")
local utils = require("colab.vendored.sg.utils")

local M = {}

---@type table<string, ColabMessageHandler?>
M.message_callbacks = {}

vim.lsp.handlers["chat/updateMessageInProgress"] = function(_, noti, ctx)
  if not noti or not noti.value or not noti.token then
    return
  end

  if not noti.value.text then
    M.message_callbacks[noti.token] = nil
    return
  end

  local notification_callback = M.message_callbacks[noti.token]
  if notification_callback and noti.value.text then
    notification_callback({
      speaker = noti.value.speaker,
      text = vim.trim(noti.value.text), -- trim random white space
      -- contextFiles = noti.value.contextFiles,
      messageId = noti.token,
    })
  end
end

_SG_CODY_RPC_MESSAGES = _SG_CODY_RPC_MESSAGES or {}
M.messages = _SG_CODY_RPC_MESSAGES

M.execute = {}

--- Execute a chat question and get a streaming response
---@param message string
---@param callback ColabMessageHandler
---@param msg_type string
---@return table | nil
---@return table | nil
M.execute.chat = function(message, callback, msg_type)
  if client.get_client() == nil then
    callback({
      speaker = "cody",
      text = "LLM LSP is not connected",
    })
    return
  end

  local message_id = utils.uuid()
  M.message_callbacks[message_id] = callback

  return client.request(
    "chat/execMessage",
    { id = msg_type, humanChatInput = message, messageId = message_id },
    function(err, _)
      if err ~= nil then
        -- Notify user of error message
        callback({
          speaker = "cody",
          text = err.message,
          messageId = message_id,
        })

        -- Mark callback as "completed"
        ---@diagnostic disable-next-line: param-type-mismatch
        callback(nil)
      end
    end
  )
end

--- Execute a chat question and get a streaming response
---@param message string
---@param callback ColabMessageHandler
---@return table | nil
---@return table | nil
M.execute.chat_question = function(message, callback)
  M.execute.chat(message, callback, "chat-question")
end

--- Execute a code question and get a streaming response
--- Returns only code (hopefully)
---@param message string
---@param callback ColabMessageHandler
---@return table | nil
M.execute.code_question = function(message, callback)
  M.execute.chat(message, callback, "code-question")
end

M.transcript = {}

M.transcript.reset = function()
  return M.notify("transcript/reset", {})
end

return M
