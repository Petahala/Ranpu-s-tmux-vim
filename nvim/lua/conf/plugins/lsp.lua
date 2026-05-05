return {
  "neovim/nvim-lspconfig",
  dependencies = {
    "williamboman/mason.nvim",
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    "hrsh7th/nvim-cmp",
    "hrsh7th/cmp-nvim-lsp",
    "hrsh7th/cmp-buffer",
    "hrsh7th/cmp-path",
  },

  config = function()
    local cmp = require("cmp")
    local cmp_nvim_lsp = require("cmp_nvim_lsp")
    local capabilities = cmp_nvim_lsp.default_capabilities()
    local servers = {
      "clangd",
      "pyright",
    }
    local mason_packages = {
      "clangd",
      "pyright",
      "stylua",
    }

    vim.api.nvim_create_autocmd("LspAttach", {
      desc = "LSP actions",
      callback = function(event)
        local opts = { buffer = event.buf }

        vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
        vim.keymap.set("n", "<leader>k", vim.diagnostic.open_float, opts)
        vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
        vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
        vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
        vim.keymap.set("n", "go", vim.lsp.buf.type_definition, opts)
        vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
        vim.keymap.set("n", "gs", vim.lsp.buf.signature_help, opts)
        vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)
        vim.keymap.set("n", "]d", vim.diagnostic.goto_next, opts)
        vim.keymap.set("n", "<F2>", vim.lsp.buf.rename, opts)
        vim.keymap.set("n", "<F4>", vim.lsp.buf.code_action, opts)
      end,
    })

    vim.diagnostic.config({
      virtual_text = true,
      signs = true,
      underline = true,
      update_in_insert = false,
      severity_sort = true,
      float = {
        border = "rounded",
        source = "if_many",
      },
    })

    local signs = {
      Error = "E",
      Warn = "W",
      Hint = "H",
      Info = "I",
    }

    for type, icon in pairs(signs) do
      local hl = "DiagnosticSign" .. type
      vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
    end

    require("mason").setup()

    require("mason-tool-installer").setup({
      ensure_installed = mason_packages,
      auto_update = false,
      run_on_start = true,
      start_delay = 3000,
      debounce_hours = 12,
    })

    vim.lsp.config("clangd", {
      capabilities = capabilities,
      cmd = {
        "C:\\Program Files\\LLVM\\bin\\clangd.exe",
        "--background-index",
        "--clang-tidy",
        "--completion-style=detailed",
        "--query-driver=**",
      },
    })

    vim.lsp.config("pyright", {
      capabilities = capabilities,
    })

    vim.lsp.enable(servers)

    vim.api.nvim_create_user_command("LspRestart", function()
      local bufnr = vim.api.nvim_get_current_buf()
      local clients = vim.lsp.get_clients({ bufnr = bufnr })

      if vim.tbl_isempty(clients) then
        vim.notify("No LSP clients attached to the current buffer.", vim.log.levels.WARN)
        return
      end

      local names = {}
      for _, client in ipairs(clients) do
        table.insert(names, client.name)
        vim.lsp.stop_client(client.id)
      end

      vim.defer_fn(function()
        vim.cmd.edit()
        vim.notify("Restarted LSP: " .. table.concat(names, ", "))
      end, 200)
    end, { desc = "Restart LSP for current buffer" })

    local kind_icons = {
      Text = "[TXT]",
      Method = "[M]",
      Function = "[FUN]",
      Constructor = "[CTOR]",
      Field = "[FLD]",
      Variable = "[VAR]",
      Class = "[CLS]",
      Interface = "[IF]",
      Module = "[MOD]",
      Property = "[PROP]",
      Unit = "[UNIT]",
      Value = "[VAL]",
      Enum = "[ENUM]",
      Keyword = "[KEY]",
      Snippet = "[SNP]",
      Color = "[CLR]",
      File = "[FILE]",
      Reference = "[REF]",
      Folder = "[DIR]",
      EnumMember = "[EM]",
      Constant = "[CONST]",
      Struct = "[STRUCT]",
      Event = "[EVT]",
      Operator = "[OP]",
      TypeParameter = "[TYPE]",
    }

    cmp.setup({
      sources = {
        { name = "nvim_lsp" },
        { name = "path" },
        { name = "buffer" },
      },
      completion = {
        completeopt = "menu,menuone,noinsert",
      },
      preselect = cmp.PreselectMode.None,
      mapping = {
        ["<C-k>"] = cmp.mapping.select_prev_item(),
        ["<C-j>"] = cmp.mapping.select_next_item(),
        ["<C-b>"] = cmp.mapping(cmp.mapping.scroll_docs(-1), { "i", "c" }),
        ["<C-f>"] = cmp.mapping(cmp.mapping.scroll_docs(1), { "i", "c" }),
        ["<C-Space>"] = cmp.mapping(cmp.mapping.complete(), { "i", "c" }),
        ["<C-y>"] = cmp.config.disable,
        ["<C-e>"] = cmp.mapping({
          i = cmp.mapping.abort(),
          c = cmp.mapping.close(),
        }),
        ["<CR>"] = cmp.mapping.confirm({ select = false }),
        ["<Tab>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_next_item()
          else
            fallback()
          end
        end, { "i", "s" }),
        ["<S-Tab>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_prev_item()
          else
            fallback()
          end
        end, { "i", "s" }),
      },
      formatting = {
        fields = { "kind", "abbr", "menu" },
        format = function(entry, vim_item)
          vim_item.kind = kind_icons[vim_item.kind] or vim_item.kind
          vim_item.menu = ({
            nvim_lsp = "[LSP]",
            path = "[Path]",
            buffer = "[Buffer]",
          })[entry.source.name]
          return vim_item
        end,
      },
    })
  end,
}
