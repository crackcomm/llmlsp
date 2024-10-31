local Speaker = require("colab.chat.types").Speaker

---@class CodyMessage
---@field speaker CodySpeaker
---@field msg string[]
---@field contextFiles ColabContextFile[]?
---@field hidden boolean
---@field completed boolean
local Message = {}
Message.__index = Message

---comment
---@param speaker CodySpeaker
---@param msg string[]
---@param contextFiles ColabContextFile[]?
---@param opts { hidden: boolean? }?
---@return CodyMessage
function Message.init(speaker, msg, contextFiles, opts)
  opts = opts or {}

  return setmetatable({
    speaker = speaker,
    msg = msg,
    contextFiles = contextFiles,
    hidden = opts.hidden,
    completed = speaker ~= Speaker.assistant,
  }, Message)
end

function Message:mark_complete()
  self.completed = true
end

---@return string[]
function Message:render()
  if self.hidden then
    return {}
  end

  if self.speaker == Speaker.assistant then
    local out = {}
    if self.contextFiles and #self.contextFiles > 0 then
      table.insert(out, "{{{ " .. tostring(#self.contextFiles) .. " context files")
      for _, v in ipairs(self.contextFiles) do
        table.insert(out, "- " .. v.fileName)
      end
      table.insert(out, "}}}")
      table.insert(out, "")
    end

    for _, line in ipairs(self.msg) do
      table.insert(out, line)
    end
    return out
  elseif self.speaker == Speaker.user then
    return vim.tbl_map(function(row)
      return "> " .. row
    end, self.msg)
  else
    return self.msg
  end
end

return Message
