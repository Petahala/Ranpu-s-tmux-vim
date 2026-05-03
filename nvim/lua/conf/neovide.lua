if not vim.g.neovide then
  return
end

local function apply_neovide_theme()
  vim.opt.background = "dark"
  pcall(vim.cmd.colorscheme, "tokyonight-night")
end

apply_neovide_theme()

vim.g.neovide_cursor_animation_length = 0.15
vim.g.neovide_cursor_short_animation_length = 0.04
vim.g.neovide_cursor_trail_size = 0.5
vim.g.neovide_cursor_antialiasing = true
vim.g.neovide_cursor_animate_in_insert_mode = true
vim.g.neovide_cursor_animate_command_line = true
vim.g.neovide_scroll_animation_length = 0.2
vim.g.neovide_position_animation_length = 0.12
vim.g.neovide_cursor_vfx_mode = ""

vim.keymap.set("n", "<C-=>", function()
  vim.g.neovide_scale_factor = (vim.g.neovide_scale_factor or 1.0) * 1.1
end, { desc = "Neovide zoom in" })

vim.keymap.set("n", "<C-->", function()
  vim.g.neovide_scale_factor = (vim.g.neovide_scale_factor or 1.0) / 1.1
end, { desc = "Neovide zoom out" })

vim.keymap.set("n", "<C-0>", function()
  vim.g.neovide_scale_factor = 1.0
end, { desc = "Neovide zoom reset" })

vim.api.nvim_create_autocmd({ "UIEnter", "VimEnter" }, {
  callback = apply_neovide_theme,
})
