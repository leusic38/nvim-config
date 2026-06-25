-- filepath: ~/.config/nvim/lua/plugins/bufferline.lua
return {
  "akinsho/bufferline.nvim",
  event = "VeryLazy",
  dependencies = {
    "nvim-tree/nvim-web-devicons",
    "catppuccin/nvim", -- ou votre colorscheme
  },
  opts = {
    options = {
      -- Configuration de base
      diagnostics = "nvim_lsp",
      separator_style = "slant",
      offsets = {
        {
          filetype = "neo-tree",
          text = "File Explorer",
          highlight = "Directory",
          text_align = "left",
        },
      },
    },
  },
  config = function(_, opts)
    -- S'assurer que le colorscheme est chargé avant bufferline
    vim.schedule(function()
      require("bufferline").setup(opts)
    end)
  end,
}
