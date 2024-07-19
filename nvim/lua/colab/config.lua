---@tag colab.setup

---@class colab.config
---@field cmd table?: llmlsp command
---@field on_attach function?: function to run when attaching lsp

---@type colab.config
local config = {
  cmd = { "/home/pah/ocxmr-repos/colab/bazel-bin/colab/llmlsp/llmlsp_/llmlsp", "--log-file=/tmp/llmlsp.log" },

  on_attach = function(...)
    -- empty
  end,

  testing = (vim.env.COLAB_NVIM_TESTING or "") == "true",
}

return config
