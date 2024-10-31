local lspconfig = require("lspconfig")
local keymaps = require("colab.chat.keymaps")

local M = {}

M.on_attach = function(client, bufnr)
  if pcall(require, "inlay-hints") then
    require("inlay-hints").on_attach(client, bufnr)
  end
  keymaps.on_attach(client, bufnr)
end

M.default_config = {
  cmd = {
    vim.env.HOME .. "/x/llmlsp/bazel-bin/llmlsp/llmlsp_/llmlsp",
    "--log-file=/tmp/llmlsp.log",
  },
  on_attach = M.on_attach,
  -- filetypes = { "go", "log" },
  root_dir = function(fname)
    return lspconfig.util.find_git_ancestor(fname)
  end,
  testing = (vim.env.COLAB_NVIM_TESTING or "") == "true",
  settings = {
    llmlsp = {
      colab = {
        url = "TODO",
        accessToken = "TODO",
      },
    },
  },
}

M.setup = function(opts)
  opts = opts or {}

  local config = vim.tbl_deep_extend("force", M.default_config, opts)

  require("colab.lsp").setup(config)
  require("colab.chat")
  require("colab.chat.keymaps").on_init()
end

return M
