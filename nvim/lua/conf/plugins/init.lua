return {
  require("conf.plugins.tokyonight"),
  require("conf.plugins.autopair"),
  require("conf.plugins.tree"),
  require("conf.plugins.treesitter"),
  require("conf.plugins.telescope"),
  require("conf.plugins.lsp"),
  require("conf.plugins.smear-cursor"),
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("lualine").setup()
    end,
  },

  {
    "christoomey/vim-tmux-navigator",
  },
}
