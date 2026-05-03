local opts = { noremap = true, silent = true }

local term_opts = { silent = true }

-- Shorten function name
local keymap = vim.api.nvim_set_keymap

local function ps_quote(value)
  return "'" .. value:gsub("'", "''") .. "'"
end

local cpp_compiler = "D:\\programs\\mingw\\bin\\g++.exe"
local c_compiler = "D:\\programs\\mingw\\bin\\gcc.exe"

local function refresh_compile_commands()
  local cwd = vim.fn.getcwd()
  local cmake_file = vim.fs.joinpath(cwd, "CMakeLists.txt")

  if vim.fn.filereadable(cmake_file) == 0 then
    vim.notify("No CMakeLists.txt found in current working directory.", vim.log.levels.WARN)
    return
  end

  local previous_window = vim.api.nvim_get_current_win()
  local build_dir = vim.fs.joinpath(cwd, "build-clangd")

  vim.cmd("botright 12split")
  local terminal_window = vim.api.nvim_get_current_win()
  local terminal_buffer = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_win_set_buf(terminal_window, terminal_buffer)
  vim.bo[terminal_buffer].bufhidden = "wipe"

  local command = table.concat({
    "$src = " .. ps_quote(cwd),
    "$build = " .. ps_quote(build_dir),
    "$cc = " .. ps_quote(c_compiler),
    "$cxx = " .. ps_quote(cpp_compiler),
    'Write-Host "Refreshing compile_commands.json ..." -ForegroundColor Cyan',
    "& cmake -S $src -B $build -G Ninja -DCMAKE_C_COMPILER=$cc -DCMAKE_CXX_COMPILER=$cxx -DCMAKE_EXPORT_COMPILE_COMMANDS=ON",
    "$exitCode = $LASTEXITCODE",
    'Write-Host ""',
    'Read-Host "Done. Press Enter to return" | Out-Null',
    "exit $exitCode",
  }, "\n")

  vim.fn.termopen({
    "powershell",
    "-NoLogo",
    "-NoProfile",
    "-Command",
    command,
  }, {
    cwd = cwd,
    on_exit = function()
      vim.schedule(function()
        if vim.api.nvim_win_is_valid(terminal_window) then
          vim.api.nvim_win_close(terminal_window, true)
        end
        if vim.api.nvim_win_is_valid(previous_window) then
          vim.api.nvim_set_current_win(previous_window)
        end
      end)
    end,
  })

  vim.cmd.startinsert()
end

local function cmake_build_project()
  local cwd = vim.fn.getcwd()
  local cmake_file = vim.fs.joinpath(cwd, "CMakeLists.txt")

  if vim.fn.filereadable(cmake_file) == 0 then
    vim.notify("No CMakeLists.txt found in current working directory.", vim.log.levels.WARN)
    return
  end

  vim.cmd.write()

  local previous_window = vim.api.nvim_get_current_win()
  local build_dir = vim.fs.joinpath(cwd, "build-clangd")

  vim.cmd("botright 12split")
  local terminal_window = vim.api.nvim_get_current_win()
  local terminal_buffer = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_win_set_buf(terminal_window, terminal_buffer)
  vim.bo[terminal_buffer].bufhidden = "wipe"

  local command = table.concat({
    "$build = " .. ps_quote(build_dir),
    'Write-Host "Building CMake project ..." -ForegroundColor Cyan',
    "& cmake --build $build",
    "$exitCode = $LASTEXITCODE",
    'Write-Host ""',
    'Read-Host "Build finished. Press Enter to return" | Out-Null',
    "exit $exitCode",
  }, "\n")

  vim.fn.termopen({
    "powershell",
    "-NoLogo",
    "-NoProfile",
    "-Command",
    command,
  }, {
    cwd = cwd,
    on_exit = function()
      vim.schedule(function()
        if vim.api.nvim_win_is_valid(terminal_window) then
          vim.api.nvim_win_close(terminal_window, true)
        end
        if vim.api.nvim_win_is_valid(previous_window) then
          vim.api.nvim_set_current_win(previous_window)
        end
      end)
    end,
  })

  vim.cmd.startinsert()
end

local function build_and_run_current_file()
  local mode = vim.api.nvim_get_mode().mode
  if mode:sub(1, 1) == "i" then
    vim.cmd.stopinsert()
  end

  local file = vim.api.nvim_buf_get_name(0)
  if file == "" then
    vim.notify("Current buffer has no file path.", vim.log.levels.WARN)
    return
  end

  local ext = vim.fn.fnamemodify(file, ":e"):lower()
  if not vim.tbl_contains({ "c", "cc", "cpp", "cxx" }, ext) then
    vim.notify("F5 build-run is only configured for C/C++ files.", vim.log.levels.WARN)
    return
  end

  vim.cmd.write()

  local source_path = vim.fn.fnamemodify(file, ":p")
  local file_dir = vim.fn.fnamemodify(source_path, ":h")
  local file_stem = vim.fn.fnamemodify(source_path, ":t:r")
  local output_path = file_dir .. "\\" .. file_stem .. ".exe"
  local previous_window = vim.api.nvim_get_current_win()

  vim.cmd("botright 12split")
  local terminal_window = vim.api.nvim_get_current_win()
  local terminal_buffer = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_win_set_buf(terminal_window, terminal_buffer)
  vim.bo[terminal_buffer].bufhidden = "wipe"

  local command = table.concat({
    "$src = " .. ps_quote(source_path),
    "$out = " .. ps_quote(output_path),
    "$compiler = " .. ps_quote(cpp_compiler),
    'Write-Host "Compiling $src ..." -ForegroundColor Cyan',
    "& $compiler -std=c++20 -g $src -o $out",
    "if ($LASTEXITCODE -ne 0) {",
    '  Write-Host ""',
    '  Read-Host "Build failed. Press Enter to return" | Out-Null',
    "  exit $LASTEXITCODE",
    "}",
    'Write-Host ""',
    'Read-Host "Build succeeded. Press Enter to run" | Out-Null',
    'Write-Host ""',
    "& $out",
    "$exitCode = $LASTEXITCODE",
    'Write-Host ""',
    'Read-Host "Program finished. Press Enter to return" | Out-Null',
    "exit $exitCode",
  }, "\n")

  vim.fn.termopen({
    "powershell",
    "-NoLogo",
    "-NoProfile",
    "-Command",
    command,
  }, {
    cwd = file_dir,
    on_exit = function()
      vim.schedule(function()
        if vim.api.nvim_win_is_valid(terminal_window) then
          vim.api.nvim_win_close(terminal_window, true)
        end
        if vim.api.nvim_win_is_valid(previous_window) then
          vim.api.nvim_set_current_win(previous_window)
        end
      end)
    end,
  })

  vim.cmd.startinsert()
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
vim.keymap.set({ "n", "i" }, "<F5>", build_and_run_current_file, {
  silent = true,
  desc = "Build and run current C/C++ file",
})
vim.keymap.set("n", "<F6>", refresh_compile_commands, {
  silent = true,
  desc = "Refresh compile_commands.json with CMake",
})
vim.keymap.set({ "n", "i" }, "<F7>", cmake_build_project, {
  silent = true,
  desc = "Build current CMake project",
})
