local opts = { noremap = true, silent = true }

local term_opts = { silent = true }

-- Shorten function name
local keymap = vim.api.nvim_set_keymap

local function ps_quote(value)
  return "'" .. value:gsub("'", "''") .. "'"
end

local cpp_compiler = "D:\\programs\\mingw\\bin\\g++.exe"
local c_compiler = "D:\\programs\\mingw\\bin\\gcc.exe"
local build_terminal = {
  buf = nil,
  win = nil,
  job = nil,
}

local function is_valid_window(win)
  return type(win) == "number" and win > 0 and pcall(vim.api.nvim_win_get_buf, win)
end

local function ensure_build_terminal_window()
  local previous_window = vim.api.nvim_get_current_win()

  if not is_valid_window(build_terminal.win) then
    vim.cmd("botright 12split")
    build_terminal.win = vim.api.nvim_get_current_win()
  end

  if is_valid_window(previous_window) then
    vim.api.nvim_set_current_win(previous_window)
  end

  return build_terminal.win
end

local function reset_build_terminal_session()
  if build_terminal.job then
    pcall(vim.fn.jobstop, build_terminal.job)
    build_terminal.job = nil
  end

  if build_terminal.buf and vim.api.nvim_buf_is_valid(build_terminal.buf) then
    pcall(vim.api.nvim_buf_delete, build_terminal.buf, { force = true })
    build_terminal.buf = nil
  end
end

local function open_build_terminal(lines, cwd)
  local previous_window = vim.api.nvim_get_current_win()
  local win = ensure_build_terminal_window()

  reset_build_terminal_session()

  if not is_valid_window(win) then
    vim.cmd("botright 12split")
    win = vim.api.nvim_get_current_win()
    build_terminal.win = win
  end

  build_terminal.buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_win_set_buf(win, build_terminal.buf)
  vim.bo[build_terminal.buf].bufhidden = "hide"
  vim.api.nvim_buf_set_name(build_terminal.buf, "Build Terminal")

  local statements = {
    "$Host.UI.RawUI.WindowTitle = 'Build Terminal'",
    "$ErrorActionPreference = 'Continue'",
    "Set-Location -LiteralPath " .. ps_quote(cwd),
  }

  vim.list_extend(statements, lines)

  local command = "& { " .. table.concat(statements, "; ") .. " }"

  vim.api.nvim_set_current_win(win)
  build_terminal.job = vim.fn.termopen({
    "powershell",
    "-NoLogo",
    "-NoProfile",
    "-NoExit",
    "-Command",
    command,
  })

  if is_valid_window(previous_window) then
    vim.api.nvim_set_current_win(previous_window)
  end
end

local function get_current_c_family_file(action_name)
  local mode = vim.api.nvim_get_mode().mode
  if mode:sub(1, 1) == "i" then
    vim.cmd.stopinsert()
  end

  local file = vim.api.nvim_buf_get_name(0)
  if file == "" then
    vim.notify("Current buffer has no file path.", vim.log.levels.WARN)
    return nil
  end

  local ext = vim.fn.fnamemodify(file, ":e"):lower()
  if not vim.tbl_contains({ "c", "cc", "cpp", "cxx" }, ext) then
    vim.notify(action_name .. " is only configured for C/C++ files.", vim.log.levels.WARN)
    return nil
  end

  local source_path = vim.fn.fnamemodify(file, ":p")
  local file_dir = vim.fn.fnamemodify(source_path, ":h")
  local file_stem = vim.fn.fnamemodify(source_path, ":t:r")
  local output_path = file_dir .. "\\" .. file_stem .. ".exe"

  return {
    source_path = source_path,
    file_dir = file_dir,
    output_path = output_path,
  }
end

local function refresh_compile_commands()
  local cwd = vim.fn.getcwd()
  local cmake_file = vim.fs.joinpath(cwd, "CMakeLists.txt")

  if vim.fn.filereadable(cmake_file) == 0 then
    vim.notify("No CMakeLists.txt found in current working directory.", vim.log.levels.WARN)
    return
  end
  local build_dir = vim.fs.joinpath(cwd, "build-clangd")

  open_build_terminal({
    "$src = " .. ps_quote(cwd),
    "$build = " .. ps_quote(build_dir),
    "$cc = " .. ps_quote(c_compiler),
    "$cxx = " .. ps_quote(cpp_compiler),
    'Write-Host "Refreshing compile_commands.json ..." -ForegroundColor Cyan',
    "& cmake -S $src -B $build -G Ninja -DCMAKE_C_COMPILER=$cc -DCMAKE_CXX_COMPILER=$cxx -DCMAKE_EXPORT_COMPILE_COMMANDS=ON",
  }, cwd)
end

local function cmake_build_project()
  local cwd = vim.fn.getcwd()
  local cmake_file = vim.fs.joinpath(cwd, "CMakeLists.txt")

  if vim.fn.filereadable(cmake_file) == 0 then
    vim.notify("No CMakeLists.txt found in current working directory.", vim.log.levels.WARN)
    return
  end

  vim.cmd.write()

  local build_dir = vim.fs.joinpath(cwd, "build-clangd")

  open_build_terminal({
    "$build = " .. ps_quote(build_dir),
    'Write-Host "Building CMake project ..." -ForegroundColor Cyan',
    "& cmake --build $build",
  }, cwd)
end

local function build_current_file()
  local file_info = get_current_c_family_file("F5 compile")
  if not file_info then
    return
  end

  vim.cmd.write()

  open_build_terminal({
    "$src = " .. ps_quote(file_info.source_path),
    "$out = " .. ps_quote(file_info.output_path),
    "$compiler = " .. ps_quote(cpp_compiler),
    'Write-Host "Compiling $src ..." -ForegroundColor Cyan',
    "& $compiler -std=c++20 -g $src -o $out",
  }, file_info.file_dir)
end

local function run_current_file()
  local file_info = get_current_c_family_file("F6 run")
  if not file_info then
    return
  end

  open_build_terminal({
    "$out = " .. ps_quote(file_info.output_path),
    "if (Test-Path -LiteralPath $out) {",
    '  Write-Host "Running $out ..." -ForegroundColor Green',
    "  & $out",
    "} else {",
    '  Write-Host "Executable not found. Compile first with F5." -ForegroundColor Yellow',
    "}",
  }, file_info.file_dir)
end

--Remap space as leader key
keymap("", "<Space>", "<Nop>", opts)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Modes
--   normal_mode = "n",
--   insert_mode = "i",
--   visual_mode = "v",
--   visual_block_mode = "x",
--   term_mode = "t",
--   command_mode = "c",

-- Normal --
-- Better window navigation
keymap("n", "<C-h>", "<C-w>h", opts)
keymap("n", "<C-j>", "<C-w>j", opts)
keymap("n", "<C-k>", "<C-w>k", opts)
keymap("n", "<C-l>", "<C-w>l", opts)

keymap("n", "<C-d>", "<C-d>zz", opts)
keymap("n", "<C-u>", "<C-u>zz", opts)

--keymap("n", "<leader>e", ":Lex 30<cr>", opts)

-- Resize with arrows
keymap("n", "<C-Up>", ":resize +1<CR>", opts)
keymap("n", "<C-Down>", ":resize -1<CR>", opts)
keymap("n", "<C-Left>", ":vertical resize -1<CR>", opts)
keymap("n", "<C-Right>", ":vertical resize +1<CR>", opts)

-- Navigate buffers
keymap("n", "<S-l>", ":bnext<CR>", opts)
keymap("n", "<S-h>", ":bprevious<CR>", opts)

-- Insert --
-- Press jk fast to enter
-- keymap("i", "jk", "<ESC>", opts)

-- Visual --
-- Stay in indent mode
-- keymap("v", "<", "<gv", opts)
-- keymap("v", ">", ">gv", opts)

keymap("n", "Q", "<nop>", opts)

-- Move text up and down
keymap("v", "<A-j>", ":m .+1<CR>==", opts)
keymap("v", "<A-k>", ":m .-2<CR>==", opts)
keymap("v", "p", '"_dP', opts)

-- Visual Block --
-- Move text up and down
keymap("x", "J", ":move '>+1<CR>gv=gv", opts)
keymap("x", "K", ":move '<-2<CR>gv=gv", opts)
keymap("x", "<A-j>", ":move '>+1<CR>gv=gv", opts)
keymap("x", "<A-k>", ":move '<-2<CR>gv=gv", opts)
keymap("x", "p", '"_dP', opts)

-- Terminal --
-- Better terminal navigation
keymap("t", "<C-h>", "<C-\\><C-N><C-w>h", term_opts)
keymap("t", "<C-j>", "<C-\\><C-N><C-w>j", term_opts)
keymap("t", "<C-k>", "<C-\\><C-N><C-w>k", term_opts)
keymap("t", "<C-l>", "<C-\\><C-N><C-w>l", term_opts)
vim.keymap.set("n", "<leader>e", ":NvimTreeToggle<CR>", { silent = true })
vim.keymap.set({ "n", "i" }, "<F5>", build_current_file, {
  silent = true,
  desc = "Compile current C/C++ file",
})
vim.keymap.set({ "n", "i" }, "<F6>", run_current_file, {
  silent = true,
  desc = "Run current C/C++ executable",
})
vim.keymap.set("n", "<F8>", refresh_compile_commands, {
  silent = true,
  desc = "Refresh compile_commands.json with CMake",
})
vim.keymap.set({ "n", "i" }, "<F7>", cmake_build_project, {
  silent = true,
  desc = "Build current CMake project",
})
