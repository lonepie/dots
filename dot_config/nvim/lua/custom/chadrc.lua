-- Just an example, supposed to be placed in /lua/custom/

local M = {}

-- make sure you maintain the structure of `core/default_config.lua` here,
-- example of changing theme:
M.ui = {
  transparency = true,
  theme = "chadracula",
}

-- if vim.g.neovide == 1 then
--   M.ui = {
--     transparency = false,
--     theme = "chadracula",
--   }
--   -- M.ui.transparency = false;
-- end

if vim.g.neovide
  then
    M.ui.transparency = false
  end


local userPlugins = require "custom.plugins"

M.plugins = {
  user = userPlugins
}

-- M.plugins = {
--   user = {
--   }
-- }

M.mappings = require "custom.mappings"

return M
