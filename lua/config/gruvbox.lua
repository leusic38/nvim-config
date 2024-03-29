-- Gruvbox configuration
-- https://github.com/ellisonleao/gruvbox.nvim

local M = {}

function M.setup()
  vim.cmd('colorscheme gruvbox')
  vim.o.background = "dark"
  require("gruvbox").setup{
    undercurl = true,
    underline = true,
    bold = true,
    italic = true,
    strikethrough = true,
    invert_selection = false,
    invert_signs = false,
    invert_tabline = false,
    invert_intend_guides = false,
    inverse = true, -- invert background for search, diffs, statuslines and errors
    contrast = "", -- can be "hard", "soft" or empty string
    palette_overrides = {},
    overrides = {},
    dim_inactive = false,
    transparent_mode = false,
  }
end

return M
