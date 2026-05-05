if not vim.g.neovide then
  return
end

local last_cwd_file = vim.fn.stdpath("state") .. "/neovide_last_cwd.txt"

local function apply_neovide_theme()
  vim.opt.background = "dark"
  pcall(vim.cmd.colorscheme, "tokyonight-night")
end

local function restore_last_cwd()
  if vim.fn.argc() > 0 or vim.fn.filereadable(last_cwd_file) == 0 then
    return
  end

  local lines = vim.fn.readfile(last_cwd_file)
  local last_cwd = lines[1]
  if not last_cwd or last_cwd == "" or vim.fn.isdirectory(last_cwd) == 0 then
    return
  end

  vim.cmd.cd(vim.fn.fnameescape(last_cwd))
end

local function save_current_cwd()
  local cwd = vim.fn.getcwd()
  if cwd == "" then
    return
  end

  vim.fn.mkdir(vim.fn.fnamemodify(last_cwd_file, ":h"), "p")
  vim.fn.writefile({ cwd }, last_cwd_file)
end

apply_neovide_theme()
restore_last_cwd()

vim.g.neovide_cursor_animation_length = 0.18
vim.g.neovide_cursor_short_animation_length = 0.05
vim.g.neovide_cursor_trail_size = 0.35
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

vim.api.nvim_create_autocmd("VimLeavePre", {
  callback = save_current_cwd,
})
