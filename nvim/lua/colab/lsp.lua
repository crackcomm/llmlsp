local lspconfig = require("lspconfig")
local configs = require("lspconfig.configs")
local keymaps = require("colab.chat.keymaps")

local setup = function(opt)
  if not configs.llmlsp then
    configs.llmlsp = {
      default_config = {
        cmd = opt.cmd,
        -- filetypes = { "go", "log" },
        root_dir = function(fname)
          return lspconfig.util.find_git_ancestor(fname)
        end,
        settings = {},
      },
    }
  end

  lspconfig.llmlsp.setup({
    on_attach = function(client, bufnr)
      -- TODO:
      -- opt.on_attach()
      if pcall(require, "inlay-hints") then
        require("inlay-hints").on_attach(client, bufnr)
      end
      keymaps.on_attach(client, bufnr)
    end,

    settings = {
      llmlsp = {
        colab = {
          url = "TODO",
          accessToken = "TODO",
          uidFile = "/tmp/sguid",
        },
      },
    },
  })
end

return { setup = setup }
