-- Credit: based on sg.nvim cody rpc

local log = require("colab.log")
local utils = require("colab.utils")
local Speaker = require("colab.chat.types").Speaker

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

---@type table<string, ChatMessageHandler?>
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

_LLMLSP_RPC_MESSAGES = _LLMLSP_RPC_MESSAGES or {}
M.messages = _LLMLSP_RPC_MESSAGES

M.execute = {}

--- Execute a chat question and get a streaming response
---@param message string
---@param callback ChatMessageHandler
---@param msg_type string
---@return table | nil
---@return table | nil
M.execute.chat = function(message, callback, msg_type)
  if M.get_client() == nil then
    callback({
      speaker = Speaker.assistant,
      text = "LLM LSP is not connected",
    })
    return
  end

  local message_id = utils.uuid()
  M.message_callbacks[message_id] = function(...)
    callback(...)
    log.trace("Message callback", ...)
  end

  return M.request(
    "chat/execMessage",
    { id = msg_type, humanChatInput = message, messageId = message_id },
    function(err, _)
      if err ~= nil then
        -- Notify user of error message
        callback({
          speaker = Speaker.assistant,
          text = err.message,
          messageId = message_id,
        })
      end

      -- Mark callback as "completed"
      ---@diagnostic disable-next-line: param-type-mismatch
      callback(nil)
    end
  )
end

--- Execute a chat question and get a streaming response
---@param message string
---@param callback ChatMessageHandler
---@return table | nil
---@return table | nil
M.execute.chat_question = function(message, callback)
  M.execute.chat(message, callback, "chat-question")
end

--- Execute a code question and get a streaming response
--- Returns only code (hopefully)
---@param message string
---@param callback ChatMessageHandler
---@return table | nil
M.execute.code_question = function(message, callback)
  M.execute.chat(message, callback, "code-question")
end

M.transcript = {}

M.transcript.reset = function()
  return M.notify("transcript/reset", {})
end

return M
