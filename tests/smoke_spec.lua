-- Démarrage : bonne version, bon appname, aucune erreur.
local t = require("helpers")
t.eq(vim.fn.has("nvim-0.12"), 1, "nvim 0.12")
t.ok(vim.fn.stdpath("config"):match("neovimanu$"), "appname neovimanu")
t.eq(#vim.v.errmsg, 0, "aucune erreur au démarrage (" .. vim.v.errmsg .. ")")
t.ok(vim.fn.filereadable(vim.fn.stdpath("config") .. "/init.lua") == 1, "init.lua présent")
-- Aucun message au démarrage (avertissement d'option obsolète d'un plugin, etc.).
local messages = vim.api.nvim_exec2("messages", { output = true }).output
t.eq(messages, "", "aucun message au démarrage")
t.finish()
