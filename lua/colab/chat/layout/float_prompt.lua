local window = require("colab.utils.window")
local keymaps = require("colab.utils.keymaps")
local CodyPrompt = require("colab.chat.cody_prompt")

---@class FloatPromptOpts : CodyPromptOpts
---@field on_submit function(bufnr: number, text: string[]): void

---@class FloatPrompt : FloatPromptOpts
---@field opts FloatPromptOpts
---@field prompt CodyPrompt
local FloatPrompt = {}
FloatPrompt.__index = FloatPrompt

---comment
---@param opts FloatPromptOpts
---@return FloatPrompt
function FloatPrompt.init(opts)
  opts = opts or {}

  opts.name = "Instruction Prompt"
  opts.width = opts.width or 0.35
  opts.height = 15

  local cursor = vim.api.nvim_win_get_cursor(0)

  local line_number_width = 0
  if vim.wo.number or vim.wo.relativenumber then
    line_number_width = vim.wo.numberwidth + 1
  end
  opts.row = cursor[1]
  opts.col = cursor[2] + line_number_width

  opts.open = function(prompt)
    prompt.bufnr, prompt.win = window.create(prompt.bufnr, prompt.win, {
      relative = "win",
      width = window.calculate_width(opts.width),
      height = window.calculate_height(opts.height),
      row = window.calculate_row(opts.row),
      col = window.calculate_col(opts.col),
      style = "minimal",
      border = "rounded",
      title = " Instruction ",
      title_pos = "center",
    })
  end

  local prompt = CodyPrompt.init(opts)

  return setmetatable({
    opts = opts,
    prompt = prompt,
  }, FloatPrompt)
end

--- Show current Hovered layout
function FloatPrompt:show()
  self.prompt:show()
  self:set_keymaps()
  vim.api.nvim_create_autocmd({ "WinClosed", "BufDelete" }, {
    buffer = self.prompt.bufnr,
    once = true,
    callback = function()
      self.prompt:on_close()
    end,
  })
end

function FloatPrompt:hide()
  self.prompt:hide()
end

function FloatPrompt:on_submit()
  self.prompt:on_submit()
  self.prompt:hide()
end

function FloatPrompt:set_keymaps()
  local bufnr = self.prompt.bufnr

  keymaps.map(bufnr, "i", "<c-c>", "[colab] quit chat", function()
    self:hide()
  end)

  keymaps.map(bufnr, "n", "<ESC>", "[colab] quit chat", function()
    self:hide()
  end)

  keymaps.map(bufnr, "n", "<CR>", "[colab] submit message", function()
    self:on_submit()
  end)

  keymaps.map(bufnr, "i", "<C-CR>", "[colab] submit message", function()
    self:on_submit()
  end)

  keymaps.map(bufnr, "n", "?", "[colab] show keymaps", function()
    keymaps.help(bufnr)
  end)
end

return FloatPrompt
