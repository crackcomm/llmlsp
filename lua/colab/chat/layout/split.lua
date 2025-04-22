local log = require("colab.log")

local Message = require("colab.chat.message")
local Speaker = require("colab.chat.types").Speaker

local keymaps = require("colab.utils.keymaps")
local shared = require("colab.utils.window")
local util = require("colab.utils")

local Base = require("colab.chat.layout.base")

---@class CodyLayoutSplitOpts : CodyBaseLayoutOpts
---@field width number?
---@field state CodyState?
---@field on_submit function?

---@class CodyLayoutSplit : CodyBaseLayout
---@field opts CodyLayoutSplitOpts
---@field super CodyBaseLayout
local CodySplit = setmetatable({}, Base)
CodySplit.__index = CodySplit

---comment
---@param opts CodyLayoutSplitOpts
---@return CodyLayoutSplit
function CodySplit.init(opts)
  opts.prompt = opts.prompt or {}
  opts.history = opts.history or {}

  local width = opts.width or 50
  opts.prompt.width = width
  opts.history.width = width

  opts.prompt.height = opts.prompt.height or 20

  local line_count = vim.o.lines - vim.o.cmdheight
  if vim.o.laststatus ~= 0 then
    line_count = line_count - 1
  end

  opts.history.open = function(history)
    vim.cmd(opts.history.split or "botright vnew")

    history.win = vim.api.nvim_get_current_win()
    history.bufnr = vim.api.nvim_get_current_buf()

    vim.api.nvim_win_set_width(history.win, shared.calculate_width(opts.history.width))

    shared.make_win_minimal(history.win)
    shared.make_buf_minimal(history.bufnr)

    vim.wo[history.win].winbar = "%=Chat History%="
  end

  opts.prompt.open = function(prompt)
    vim.cmd(opts.prompt.split or "below new")
    prompt.win = vim.api.nvim_get_current_win()
    prompt.bufnr = vim.api.nvim_get_current_buf()

    vim.api.nvim_win_set_height(prompt.win, shared.calculate_height(opts.prompt.height))
    shared.make_win_minimal(prompt.win)
    shared.make_buf_minimal(prompt.bufnr)

    vim.wo[prompt.win].winbar = "Chat Prompt%=%#Comment#(`?` for help)"
  end

  local object = Base.init(opts) --[[@as CodyLayoutSplit]]

  object.super = Base
  return setmetatable(object, CodySplit) --[[@as CodyLayoutSplit]]
end

function CodySplit:set_keymaps()
  self.super.set_keymaps(self)

  keymaps.map(self.prompt.bufnr, "n", "<CR>", "[chat] submit message", function()
    self.prompt:on_submit()
  end)

  keymaps.map(self.prompt.bufnr, "i", "<C-CR>", "[chat] submit message", function()
    self.prompt:on_submit()
  end)

  keymaps.map(self.prompt.bufnr, { "i", "n" }, "<c-c>", "[chat] quit chat", function()
    self.prompt:on_close()
  end)

  keymaps.map(self.history.bufnr, "n", "<c-c>", "[chat] quit chat", function()
    self.prompt:on_close()
  end)

  local with_history = function(key, mapped)
    if not mapped then
      mapped = key
    end

    local desc = "[chat] execute '" .. key .. "' in history buffer"
    keymaps.map(self.prompt.bufnr, { "n", "i" }, key, desc, function()
      if vim.api.nvim_win_is_valid(self.history.win) then
        vim.api.nvim_win_call(self.history.win, function()
          util.execute_keystrokes(mapped)
        end)
      end
    end)
  end

  with_history("<c-f>")
  with_history("<c-b>")
  with_history("<c-e>")
  with_history("<c-y>")

  keymaps.map(self.prompt.bufnr, "n", "?", "[chat] show keymaps", function()
    keymaps.help(self.prompt.bufnr)
  end)

  keymaps.map(self.prompt.bufnr, "n", "<c-n>", "[chat] fast forward typewriter", function()
    if self.state then
      self.state:fast_forward()
    end
  end)
end

---Returns the id of the message where the completion will go
---@return number
function CodySplit:request_completion()
  self:render()
  vim.api.nvim_buf_set_lines(self.prompt.bufnr, 0, -1, false, {})

  return self.state:complete(self.history.bufnr, self.history.win, function(id)
    log.trace("requesting a completion", self.history.bufnr, self.history.win, id)

    -- TODO: THis seems wrong...
    return function(msg, err)
      log.trace("received completion", err, msg)

      if err then
        vim.notify(vim.inspect(err))
        return
      end

      if not msg then
        self.state:mark_message_complete(id)
        return
      end

      self.state:update_message(id, Message.init(Speaker.assistant, vim.split(msg.text or "", "\n"), msg.contextFiles))
      self:render()
    end
  end)
end

return CodySplit
