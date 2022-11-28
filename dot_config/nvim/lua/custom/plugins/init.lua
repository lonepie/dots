return {
  ["goolord/alpha-nvim"] = { disable = false },
  ["hashivim/vim-terraform"] = { disable = false },
  ["pearofducks/ansible-vim"] = { disable = false },
  ["folke/which-key.nvim"] = { disable = false },
  ["kylechui/nvim-surround"] = {
    disabled = false,
    config = function()
      require("nvim-surround").setup({})
    end,
  },
}
