-- example file i.e lua/custom/init.lua
local o = vim.o
local wo = vim.wo
local bo = vim.bo

wo.wrap = false

-- MAPPINGS
--["<leader>cd"] = {"<cmd> cd %:p:h"}
local map = nvchad.map

map("n", "<leader>cc", ":Telescope <CR>")
map("n", "<leader>q", ":q <CR>")
map("n", "<leader>cd", ":cd %:p:h <CR>")

-- require("my autocmds file") or just declare them here
