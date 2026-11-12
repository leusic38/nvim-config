-- Terminal (toggleterm, lazygit/lazydocker flottants) et Git (gitsigns, diffview).
local t = require("helpers")
local term = require("manu.terminal")

local function has(mode, lhs)
  for _, m in ipairs(vim.api.nvim_get_keymap(mode)) do
    if vim.fn.keytrans(m.lhsraw):gsub("^<Space>", "<leader>") == lhs then
      return m
    end
  end
end

t.ok(has("n", "<C-Bslash>"), "<C-\\> en mode normal")
t.ok(has("t", "<C-Bslash>"), "<C-\\> en mode terminal")
local od = has("n", "<leader>od")
t.eq(od and od.desc, "Lazydocker (conteneurs)", "<leader>od = Lazydocker")
t.ok(has("n", "<leader>gg"), "<leader>gg (lazygit)")

local config_real = vim.uv.fs_realpath(vim.fn.stdpath("config"))
vim.cmd("edit " .. config_real .. "/init.lua")
t.eq(term.root(), config_real, "root() = racine du worktree")

-- Commande absente : erreur signalée, pas de terminal.
local errors = {}
local notify = vim.notify
vim.notify = function(msg, level)
  if level == vim.log.levels.ERROR then
    table.insert(errors, msg)
  end
end
local before = #vim.api.nvim_list_bufs()
term.float_cmd("commande-inexistante")
vim.notify = notify
t.ok(#errors == 1 and errors[1]:find("commande%-inexistante"), "commande absente : erreur")
t.eq(#vim.api.nvim_list_bufs(), before, "commande absente : pas de terminal")

term.float_cmd("lazygit")
t.ok(t.wait(function()
  for _, b in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_get_name(b):match("^term://.*lazygit") then
      return true
    end
  end
  return false
end, 5000), "lazygit lancé dans un terminal")

t.ok(package.loaded.gitsigns ~= nil, "gitsigns chargé")
vim.cmd("edit " .. config_real .. "/init.lua")
t.ok(t.wait(function()
  for _, m in ipairs(vim.api.nvim_buf_get_keymap(0, "n")) do
    if m.lhs == "]h" then
      return true
    end
  end
  return false
end, 5000), "gitsigns attaché : ]h dans un fichier suivi")
t.eq(vim.fn.exists(":DiffviewOpen"), 2, ":DiffviewOpen existe")

t.finish()
