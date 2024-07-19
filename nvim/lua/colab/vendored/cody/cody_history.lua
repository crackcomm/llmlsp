local shared = require("colab.vendored.cody.shared")

---@class CodyHistoryOpts
---@field open function(self): Create a buf, win pair
---@field split string?
---@field height number|string
---@field width number|string
---@field row number|string
---@field col number|string
---@field filetype string?

---@class CodyHistory
---@field open function(self): Open the window and bufnr, mutating self to store new win and bufnr
---@field opts CodyHistoryOpts
---@field bufnr number
---@field win number
---@field visible boolean
local CodyHistory = {}
CodyHistory.__index = CodyHistory

--- Create a new CodyHistory
---@param opts CodyHistoryOpts
---@return CodyHistory
function CodyHistory.init(opts)
  return setmetatable({
    open = assert(opts.open, "Must have open function passed"),
    opts = opts,
    bufnr = -1,
    win = -1,
    visible = false,
  }, CodyHistory)
end

function CodyHistory:show()
  self:open()

  vim.api.nvim_buf_set_name(self.bufnr, string.format("Chat History (%d)", self.bufnr))
  vim.wo[self.win].foldmethod = "marker"

  vim.bo[self.bufnr].filetype = self.opts.filetype or "markdown.cody_history"
end

function CodyHistory:delete()
  self:hide()
  self.bufnr = shared.buf_del(self.bufnr)
end

function CodyHistory:hide()
  self.win = shared.win_del(self.win)
end

function CodyHistory:scroll_to_bottom()
  if vim.api.nvim_buf_line_count(self.bufnr) > 0 then
    pcall(vim.api.nvim_win_set_cursor, self.win, { -1, 0 })
  end
end

return CodyHistory
