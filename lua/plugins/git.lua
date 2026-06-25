return {
  {
    "sindrets/diffview.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewFileHistory" },
    keys = {
      { "<leader>gd", "<cmd>DiffviewOpen<cr>", desc = "Diff View (HEAD)" },
      { "<leader>gD", "<cmd>DiffviewClose<cr>", desc = "Fermer Diff View" },
      { "<leader>gF", "<cmd>DiffviewFileHistory %<cr>", desc = "Historique fichier (diff)" },
    },
    opts = {
      hooks = {
        diff_buf_read = function()
          vim.opt_local.wrap = false
        end,
      },
    },
  },
  {
    "olacin/telescope-cc.nvim",
    dependencies = { "nvim-telescope/telescope.nvim" },
    config = function()
      require("telescope").load_extension("conventional_commits")
    end,
    ft = { "gitcommit" },
    keys = {
      {
        "<leader>gc",
        function()
          require("telescope").extensions.conventional_commits.conventional_commits()
        end,
        desc = "Conventional Commit",
        ft = "gitcommit",
      },
    },
  },
}
