---@enum Speaker
local Speaker = { system = "system", assistant = "assistant", user = "user" }

---@class ContextFile
---@field fileName string
---@field repoName string?
---@field revision string?
---@field source string?

---@class ChatMessage
---@field speaker Speaker
---@field text string
---@field messageId string?

---@alias ChatMessageHandler fun(msg: ChatMessage)

---@alias ChatCallbackHandler fun(id: number): ChatMessageHandler

return { Speaker = Speaker }
