-- Navigation : fzf-lua (sélecteur et vim.ui.select) et Oil (remplace netrw).
local t = require("helpers")

t.ok(debug.getinfo(vim.ui.select, "S").source:find("fzf-lua", 1, true), "vim.ui.select passe par fzf-lua")
t.eq(vim.g.loaded_netrwPlugin, 1, "netrw désactivé")

local fd = require("fzf-lua.config").globals.files.fd_opts or ""
t.ok(fd:find("--exclude vendor", 1, true), "fd exclut vendor")
t.ok(fd:find("--exclude node_modules", 1, true), "fd exclut node_modules")

local maps = {}
for _, mode in ipairs({ "n", "x" }) do
  for _, m in ipairs(vim.api.nvim_get_keymap(mode)) do
    maps[mode .. vim.fn.keytrans(m.lhsraw):gsub("^<Space>", "<leader>")] = true
  end
end
for _, k in ipairs({
  "n<leader><Space>", "n<leader>ff", "n<leader>fF", "n<leader>fr", "n<leader>fc", "n<leader>,",
  "n<leader>/", "n<leader>sg", "n<leader>sw", "x<leader>sw", "n<leader>sh", "n<leader>sk",
  "n<leader>sR", "n<leader>ss", "n-", "n<leader>e",
}) do
  t.ok(maps[k], "raccourci " .. k)
end

vim.cmd("edit " .. vim.fn.stdpath("config") .. "/tests")
t.ok(t.wait(function()
  return vim.bo.filetype == "oil"
end, 5000), "ouvrir un dossier ouvre Oil")

t.finish()
