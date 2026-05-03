return {
  "sphamba/smear-cursor.nvim",
  enabled = not vim.g.neovide,
  opts = {
    smear_between_buffers = true,
    smear_between_neighbor_lines = true,
    scroll_buffer_space = true,
    smear_insert_mode = true,
  },
}
