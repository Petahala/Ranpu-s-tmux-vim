local options = {
  backup = false,
  autoread = true,
  autoindent = true,
  background = "dark",
  clipboard = "unnamedplus",
  cmdheight = 2,
  completeopt = { "menuone", "noselect" } ,
  confirm = true,
  conceallevel = 0,
  hlsearch = true,
  incsearch = true,
  ignorecase = true,
  laststatus = 2,
  mouse = "a",
  pumheight = 10,
  showmode = false,
  showtabline = 2,
  smartcase = true,
  smartindent = true,
  cindent = true,
  splitbelow = true,
  splitright = true,
  swapfile = false,
  termguicolors = true,
  timeoutlen = 1000,
  undofile = true,
  updatetime = 300,
  writebackup = false,
  expandtab = true,
  shiftwidth = 4,
  tabstop = 4,
  cursorline = false,
  number = true,
  relativenumber = false,
  numberwidth = 4,
  signcolumn = "yes",
  wrap = false,
  scrolloff = 4,
  sidescrolloff = 4,
  guifont = "Consolas:h11",
}

for k, v in pairs(options) do
    pcall(function()
        vim.opt[k] = v
    end)
end

pcall(function()
    if vim.bo.buftype == "" and vim.bo.modifiable then
        vim.bo.fileencoding = "utf-8"
    end
end)

-- Create an autocommand group for file-specific settings
vim.api.nvim_create_augroup("FileTypeSpecific", { clear = true })

-- Set shiftwidth and tabstop to 2 for HTML, CSS, JavaScript, and Lua files
vim.api.nvim_create_autocmd("FileType", {
    pattern = { "html", "css", "javascript", "lua" },
    callback = function()
        vim.opt_local.shiftwidth = 2
        vim.opt_local.tabstop = 2
    end,
    group = "FileTypeSpecific",
})

vim.api.nvim_create_autocmd("FileType", {
    pattern = { "c", "cpp" },
    callback = function()
        vim.opt_local.cindent = true
        vim.opt_local.shiftwidth = 4
        vim.opt_local.tabstop = 4
        vim.opt_local.expandtab = true
    end,
    group = "FileTypeSpecific",
})

local formatoptions_group = vim.api.nvim_create_augroup("FormatOptionsAdjustments", { clear = true })

vim.api.nvim_create_autocmd("BufEnter", {
    group = formatoptions_group,
    callback = function()
        vim.opt.formatoptions:remove({ "c", "r", "o" })
        vim.opt_local.formatoptions:remove({ "c", "r", "o" })
    end,
})

vim.opt.shortmess:append "c"

local autoread_group = vim.api.nvim_create_augroup("AutoReadExternalChanges", { clear = true })

vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold", "CursorHoldI" }, {
    group = autoread_group,
    callback = function()
        if vim.fn.getcmdwintype() ~= "" or vim.fn.mode() == "c" then
            return
        end
        vim.cmd("silent! checktime")
    end,
})

vim.api.nvim_create_autocmd("FileChangedShellPost", {
    group = autoread_group,
    callback = function()
        vim.notify("File changed on disk. Buffer reloaded.", vim.log.levels.INFO)
    end,
})
