local lspconfig = require("lspconfig")
local configs = require("lspconfig.configs")

local setup = function(opt)
  if not configs.llmlsp then
    configs.llmlsp = {
      default_config = {
        cmd = opt.cmd,
        settings = {},
      },
    }
  end

  lspconfig.llmlsp.setup(opt)
end

return { setup = setup }
