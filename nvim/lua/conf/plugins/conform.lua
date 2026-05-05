return {
  "stevearc/conform.nvim",
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    local conform = require("conform")
    local black_cmd = "D:\\msys64\\ucrt64\\bin\\black.exe"
    local clang_format_cmd = "C:\\Program Files\\LLVM\\bin\\clang-format.exe"

    conform.setup({
      formatters_by_ft = {
        c = { "clang_format" },
        cpp = { "clang_format" },
        python = { "black" },
        lua = { "stylua" },
      },
      format_on_save = function(bufnr)
        local disabled = {
          c = false,
          cpp = false,
          python = false,
          lua = false,
        }

        local ft = vim.bo[bufnr].filetype
        if disabled[ft] == nil then
          return nil
        end

        return {
          timeout_ms = 1000,
          lsp_format = "fallback",
          quiet = true,
        }
      end,
      notify_on_error = true,
      notify_no_formatters = false,
      formatters = {
        black = {
          command = black_cmd,
        },
        clang_format = {
          command = clang_format_cmd,
        },
      },
    })

    vim.keymap.set({ "n", "v" }, "<leader>f", function()
      conform.format({
        async = false,
        lsp_format = "fallback",
        timeout_ms = 1000,
      })
    end, { desc = "Format current buffer or selection" })
  end,
}
