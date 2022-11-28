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
-- if vim.fn.GuiName() == "nvim-qt" then
--   M.ui = {
--     transparency = false,
--     theme = "chadracula",
--   }
-- end

-- nvim_gui = false
-- local ok, result = pcall(vim.fn.GuiName)
-- nvim_gui = result
-- if not ok then nvim_gui = true end
-- if nvim_gui then
--   M.ui.transparency = false
-- end

-- neovide-specific options
if vim.g.neovide then
  M.ui.transparency = false
  vim.g.neovide_cursor_vfx_mode = "ripple"
end


local userPlugins = require "custom.plugins"

M.plugins = {
  user = userPlugins
}

M.mappings = require "custom.mappings"

return M
