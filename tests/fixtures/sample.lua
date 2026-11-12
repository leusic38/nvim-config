-- Fixture du test LSP : lua_ls doit signaler la globale inconnue ci-dessous.
local M = {}

function M.hello()
  vim.notify("bonjour")
  return variable_globale_inconnue
end

return M
