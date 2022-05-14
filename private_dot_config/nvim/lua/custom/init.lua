-- example file i.e lua/custom/init.lua

-- MAPPINGS
-- local map = require("core.utils").map
local map = nvchad.map

map("n", "<leader>cc", ":Telescope <CR>")
map("n", "<leader>q", ":q <CR>")
map("n", "<leader>cd", ":cd %:p:h")

-- require("my autocmds file") or just declare them here
