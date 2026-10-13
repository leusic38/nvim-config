-- Database client (DBeaver-like) on top of the LazyVim `lang.sql` extra:
-- vim-dadbod + dadbod-ui + dadbod-completion (blink source wired by the extra).
-- Connections = DBeaver store (lua/config/dbeaver.lua) + project `.nvim/dadbod.lua`.

-- Project connections from `.nvim/dadbod.lua` (`return { dbs = { { name =, url = } } }`)
local function project_dbs()
  local path = vim.fn.getcwd() .. "/.nvim/dadbod.lua"
  if vim.fn.filereadable(path) == 1 then
    local ok, config = pcall(dofile, path)
    if ok and type(config) == "table" and type(config.dbs) == "table" then
      return config.dbs
    end
  end
  return {}
end

local function load_dbs()
  local dbs = project_dbs()
  vim.list_extend(dbs, require("config.dbeaver").connections())
  vim.g.dbs = dbs
end

return {
  {
    "kristijanhusak/vim-dadbod-ui",
    dependencies = {
      { "tpope/vim-dadbod", lazy = true },
      { "kristijanhusak/vim-dadbod-completion", lazy = true },
    },
    cmd = { "DBUI", "DBUIToggle", "DBUIAddConnection", "DBUIFindBuffer" },
    keys = {
      { "<leader>Du", "<cmd>DBUIToggle<cr>", desc = "DB: Toggle UI" },
      { "<leader>Da", "<cmd>DBUIAddConnection<cr>", desc = "DB: Add connection" },
      { "<leader>Df", "<cmd>DBUIFindBuffer<cr>", desc = "DB: Find buffer" },
      { "<leader>Dr", "<cmd>DBUIRenameBuffer<cr>", desc = "DB: Rename buffer" },
      { "<leader>Dq", "<cmd>DBUILastQueryInfo<cr>", desc = "DB: Last query info" },
    },
    init = function()
      vim.g.db_ui_use_nerd_fonts = 1
      vim.g.db_ui_save_location = vim.fn.stdpath("data") .. "/db_ui"
      vim.g.db_ui_show_database_icon = 1
      vim.g.db_ui_auto_execute_table_helpers = 1
      vim.g.db_ui_win_position = "left"
      vim.g.db_ui_winwidth = 40
      vim.g.db_ui_force_echo_notifications = 0

      -- Result window: dadbod opens it as a preview window (12 lines by default)
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "dbout",
        callback = function()
          vim.cmd("resize " .. math.floor(vim.o.lines * 0.5))
          vim.opt_local.wrap = false
        end,
      })

      -- DBeaver decryption only runs when the UI is first opened, not at startup
      vim.api.nvim_create_autocmd("DirChanged", {
        callback = function()
          if package.loaded["config.dbeaver"] then
            load_dbs()
          end
        end,
      })
    end,
    config = function()
      load_dbs()
    end,
  },

  -- PostgreSQL dialect for sqlfluff (the extra defaults to ansi)
  {
    "stevearc/conform.nvim",
    optional = true,
    opts = function(_, opts)
      opts.formatters = opts.formatters or {}
      opts.formatters.sqlfluff = { args = { "format", "--dialect=postgres", "-" } }
    end,
  },
  {
    "mfussenegger/nvim-lint",
    optional = true,
    opts = function(_, opts)
      opts.linters = opts.linters or {}
      opts.linters.sqlfluff = { args = { "lint", "--format=json", "--dialect=postgres", "-" } }
    end,
  },
}
