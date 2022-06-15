local M = {}

M.normal = {
  n = {
    ["<leader>cd"] = {"<cmd> cd %:p:h <CR>", "cd to current file dir", opts = {}},
    ["<leader>cc"] = {"<cmd> :Telescope <CR>", "Open Telescope", opts = {}},
    ["<s-h>"] = {"^", "start of line"},
    ["<s-l>"] = {"$", "end of line"}
  }
}
return M
