-- args: tests/fixtures/sample.lua
-- Avec un fichier en argument : pas d'accueil.
local t = require("helpers")
t.eq(vim.bo.filetype, "lua", "le fichier est ouvert")
for _, b in ipairs(vim.api.nvim_list_bufs()) do
  t.ok(vim.bo[b].filetype ~= "manu-dashboard", "pas d'accueil")
end
t.finish()
