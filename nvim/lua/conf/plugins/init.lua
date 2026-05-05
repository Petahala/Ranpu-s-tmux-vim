return {
  require("conf.plugins.tokyonight"),
  require("conf.plugins.autopair"),
  require("conf.plugins.tree"),
  require("conf.plugins.treesitter"),
  require("conf.plugins.telescope"),
  require("conf.plugins.lsp"),
  require("conf.plugins.conform"),
  require("conf.plugins.smear-cursor"),
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("lualine").setup({
        options = {
          globalstatus = false,
          disabled_filetypes = {
            statusline = {},
            winbar = {},
          },
        },
        winbar = {},
        inactive_winbar = {},
      })
    end,
  },

  {
    "christoomey/vim-tmux-navigator",
  },
}
