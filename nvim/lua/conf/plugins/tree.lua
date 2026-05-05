return {
  "nvim-tree/nvim-tree.lua",
  version = "*",
  lazy = false,
  dependencies = {
    "nvim-tree/nvim-web-devicons",
  },
  config = function()
    local function on_attach(bufnr)
      local api = require("nvim-tree.api")
      local core = require("nvim-tree.core")

      local function opts(desc)
        return {
          desc = "nvim-tree: " .. desc,
          buffer = bufnr,
          noremap = true,
          silent = true,
          nowait = true,
        }
      end

      local function focus_first_visible_node()
        local first_line = core.get_nodes_starting_line()
        local line_count = vim.api.nvim_buf_line_count(bufnr)
        if first_line <= 0 or first_line > line_count then
          return nil
        end

        pcall(vim.api.nvim_win_set_cursor, 0, { first_line, 0 })
        return api.tree.get_node_under_cursor()
      end

      local function actionable_node()
        local node = api.tree.get_node_under_cursor()
        if node then
          return node
        end

        local explorer = core.get_explorer()
        if not explorer or not explorer.live_filter or not explorer.live_filter.filter then
          return nil
        end

        return focus_first_visible_node()
      end

      local function with_node(desc, fn)
        return function()
          local node = actionable_node()
          if not node then
            vim.notify("No nvim-tree node under cursor.", vim.log.levels.WARN)
            return
          end
          fn(node)
        end
      end

      api.map.on_attach.default(bufnr)

      vim.keymap.set("n", "<CR>", with_node("Open", api.node.open.edit), opts("Open"))
      vim.keymap.set("n", "o", with_node("Open", api.node.open.edit), opts("Open"))
      vim.keymap.set("n", "<Tab>", with_node("Open Preview", api.node.open.preview), opts("Open Preview"))
      vim.keymap.set("n", "<C-e>", with_node("Open: In Place", api.node.open.replace_tree_buffer), opts("Open: In Place"))
      vim.keymap.set("n", "<C-v>", with_node("Open: Vertical Split", api.node.open.vertical), opts("Open: Vertical Split"))
      vim.keymap.set("n", "<C-x>", with_node("Open: Horizontal Split", api.node.open.horizontal), opts("Open: Horizontal Split"))
      vim.keymap.set("n", "<C-t>", with_node("Open: New Tab", api.node.open.tab), opts("Open: New Tab"))
      vim.keymap.set("n", "<BS>", with_node("Close Directory", api.node.navigate.parent_close), opts("Close Directory"))
      vim.keymap.set("n", "P", with_node("Parent Directory", api.node.navigate.parent), opts("Parent Directory"))
      vim.keymap.set("n", "y", with_node("Copy Name", api.fs.copy.filename), opts("Copy Name"))
      vim.keymap.set("n", "Y", with_node("Copy Relative Path", api.fs.copy.relative_path), opts("Copy Relative Path"))
      vim.keymap.set("n", "gy", with_node("Copy Absolute Path", api.fs.copy.absolute_path), opts("Copy Absolute Path"))
      vim.keymap.set("n", "ge", with_node("Copy Basename", api.fs.copy.basename), opts("Copy Basename"))
      vim.keymap.set("n", "f", api.filter.live.start, opts("Live Filter: Start"))
    end

    require("nvim-tree").setup({
      on_attach = on_attach,
      sync_root_with_cwd = true,
      update_focused_file = {
        enable = true,
        update_root = true,
      },
    })

    vim.keymap.set("n", "<leader>e", ":NvimTreeToggle<cr>")
  end,
}
