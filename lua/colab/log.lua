-- Credit: sg.nvim -> log.lua

local traverse
traverse = function(t, f)
  for k, v in pairs(t) do
    f(t, k, v)

    if type(v) == "table" then
      traverse(v, f)
    end
  end
end

local logger = require("plenary.log").new({
  plugin = "colab",
  level = "debug",
  use_console = false,
  info_level = 3,
})

-- logger.

local modes = {
  "trace",
  "debug",
  "info",
  "warn",
  "error",
  "fatal",
}

local filtered_keys = {
  OPENAI_API_KEY = true,
  accessToken = true,
  token = true,
}

local shortened_keys = {
  content = true,
}

local modified = {}

for _, level in ipairs(modes) do
  modified[level] = function(...)
    local arguments = { ... }
    for idx, arg in ipairs(arguments) do
      if type(arg) == "table" then
        arg = vim.deepcopy(arg)
        traverse(arg, function(t, k, v)
          if filtered_keys[k] then
            t[k] = "**** revoked ****"
          end

          if shortened_keys[k] then
            if type(v) == "string" and #v > 15 then
              t[k] = string.sub(v, 1, 15) .. " ..."
            end
          end
        end)

        arguments[idx] = arg
      end
    end

    ---@diagnostic disable-next-line: deprecated
    logger[level](unpack(arguments))
  end
end

return modified
