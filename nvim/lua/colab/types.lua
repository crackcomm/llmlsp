-- Migrated from sg.nvim (cody)

---@class ColabContextFile
---@field fileName string
---@field repoName string?
---@field revision string?
---@field source string?

---@class ColabChatMessage
---@field speaker string
---@field text string
---@field displayText string?
---@field messageId string?

---@class ColabChatUpdateMessageInProgressNoti: ColabChatMessage
---@field text string?
---@field messageId string?

---@alias ColabMessageHandler fun(msg: ColabChatMessage)

---@alias ColabChatCallbackHandler fun(id: number): ColabMessageHandler
