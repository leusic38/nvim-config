-- args: tests/fixtures
-- « nn <dossier> » : Neovim se place dans le dossier et affiche l'accueil, pas Oil.
local t = require("helpers")

local expected = vim.uv.fs_realpath(vim.fn.stdpath("config") .. "/tests/fixtures")
t.eq(vim.uv.fs_realpath(vim.uv.cwd()), expected, "dossier courant = dossier passé en argument")
t.eq(vim.bo.filetype, "manu-dashboard", "accueil affiché (pas Oil)")
t.ok(t.wait(function()
  for _, b in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_valid(b) and vim.bo[b].filetype == "oil" then
      return false
    end
  end
  return true
end, 2000), "aucun buffer Oil restant")
t.eq(vim.fn.argc(), 0, "liste d'arguments vidée")
t.finish()
