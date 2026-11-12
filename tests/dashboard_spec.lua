-- Page d'accueil au lancement sans argument.
local t = require("helpers")

t.eq(vim.bo.filetype, "manu-dashboard", "accueil affiché sans argument")
local text = table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), "\n")
t.ok(text:find("Trouver un fichier", 1, true), "action « Trouver un fichier »")
local maps = {}
for _, m in ipairs(vim.api.nvim_buf_get_keymap(0, "n")) do
  maps[m.lhs] = true
end
for _, k in ipairs({ "f", "r", "g", "s", "e", "n", "G", "c", "m", "q", "<CR>" }) do
  t.ok(maps[k], "touche d'accueil " .. k)
end
t.eq(#vim.fn.getbufinfo({ buflisted = 1 }), 0, "aucun buffer listé (pas de [No Name] parasite)")
t.eq(vim.fn.exists(":Accueil"), 2, ":Accueil existe")

-- Ouvrir un fichier remplace l'accueil, qui disparaît.
local dash = vim.api.nvim_get_current_buf()
vim.cmd("edit " .. vim.fn.stdpath("config") .. "/init.lua")
t.ok(not vim.api.nvim_buf_is_valid(dash), "accueil effacé après ouverture d'un fichier")
t.finish()
