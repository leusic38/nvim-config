local M = {}

function M.setup()
  vim.g.everforest_background = 'soft'
  vim.g.everforest_transparent_background = 1
  vim.o.background = 'dark'
  vim.cmd('colorscheme everforest')
end

return M
