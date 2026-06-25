return {
  {
    "tpope/vim-dadbod",
    lazy = true,
  },
  {
    "kristijanhusak/vim-dadbod-ui",
    dependencies = {
      { "tpope/vim-dadbod", lazy = true },
      { "kristijanhusak/vim-dadbod-completion", ft = { "sql", "mysql", "plsql" }, lazy = true },
    },
    cmd = { "DBUI", "DBUIToggle", "DBUIAddConnection", "DBUIFindBuffer" },
    keys = {
      { "<leader>Du", "<cmd>DBUIToggle<cr>", desc = "DB: Toggle UI" },
      { "<leader>Da", "<cmd>DBUIAddConnection<cr>", desc = "DB: Add connection" },
      { "<leader>Df", "<cmd>DBUIFindBuffer<cr>", desc = "DB: Find buffer" },
    },
    init = function()
      vim.g.db_ui_use_nerd_fonts = 1
      vim.g.db_ui_save_location = vim.fn.stdpath("data") .. "/db_ui"
      vim.g.db_ui_show_database_icon = 1
      vim.g.db_ui_auto_execute_table_helpers = 1

      -- Charge les connexions du projet si elles existent dans .nvim/dadbod.lua
      local function load_project_db_config()
        local path = vim.fn.getcwd() .. "/.nvim/dadbod.lua"
        if vim.fn.filereadable(path) == 1 then
          local ok, config = pcall(dofile, path)
          if ok and type(config) == "table" then
            vim.g.dbs = config.dbs or vim.g.dbs
          end
        end
      end

      load_project_db_config()
      vim.api.nvim_create_autocmd("DirChanged", { callback = load_project_db_config })
    end,
  },
  {
    "kristijanhusak/vim-dadbod-completion",
    ft = { "sql", "mysql", "plsql" },
    lazy = true,
    config = function()
      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "sql", "mysql", "plsql" },
        callback = function()
          require("cmp").setup.buffer({
            sources = { { name = "vim-dadbod-completion" } },
          })
        end,
      })
    end,
  },
}
