-- Local training plugin. `dir` + `dev`-style local spec: the module lives in
-- this config's own lua/ tree, so we just call setup on VeryLazy.
return {
  {
    "nvimtrainer",
    dir = vim.fn.stdpath("config"),
    name = "nvimtrainer",
    event = "VeryLazy",
    keys = {
      { "<leader>tx", "<cmd>NvimTrainerStart<cr>", desc = "NvimTrainer: démarrer" },
      { "<leader>tX", "<cmd>NvimTrainerStats<cr>", desc = "NvimTrainer: stats" },
    },
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("nvimtrainer").setup({})
    end,
  },
}
