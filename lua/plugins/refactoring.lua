return {
  {
    "ThePrimeagen/refactoring.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    keys = {
      { "<leader>Rm", function() require("refactoring").select_refactor() end, mode = { "n", "x" }, desc = "Refactoring: Menu" },
      { "<leader>Re", function() require("refactoring").refactor("Extract Function") end, mode = "x", desc = "Refactoring: Extract function" },
      { "<leader>Rf", function() require("refactoring").refactor("Extract Function To File") end, mode = "x", desc = "Refactoring: Extract function to file" },
      { "<leader>Rv", function() require("refactoring").refactor("Extract Variable") end, mode = "x", desc = "Refactoring: Extract variable" },
      { "<leader>Ri", function() require("refactoring").refactor("Inline Variable") end, mode = { "n", "x" }, desc = "Refactoring: Inline variable" },
      { "<leader>Rb", function() require("refactoring").refactor("Extract Block") end, mode = "x", desc = "Refactoring: Extract block" },
      { "<leader>RF", function() require("refactoring").refactor("Extract Block To File") end, mode = "x", desc = "Refactoring: Extract block to file" },
    },
    opts = {
      show_success_message = true,
    },
    config = function(_, opts)
      require("refactoring").setup(opts)

      -- Intégration Telescope pour le menu de refactoring
      local ok, telescope = pcall(require, "telescope")
      if ok then
        telescope.load_extension("refactoring")
        vim.keymap.set({ "n", "x" }, "<leader>RT", function()
          require("telescope").extensions.refactoring.refactors()
        end, { desc = "Refactoring: Telescope menu" })
      end
    end,
  },
}
