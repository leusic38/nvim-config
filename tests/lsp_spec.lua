-- args: tests/fixtures/sample.lua
-- LSP sur un fichier passé en argument (comme « nvim foo.lua ») : client, treesitter,
-- raccourcis LSP du buffer, complétion, bibliothèque $VIMRUNTIME, diagnostics.
local t = require("helpers")

t.eq(vim.bo.filetype, "lua", "filetype lua")
local attached = t.wait(function()
  return #vim.lsp.get_clients({ bufnr = 0, name = "lua_ls" }) == 1
end, 60000)
t.ok(attached, "lua_ls attaché au buffer (premier lancement : Mason l'installe d'abord)")
t.ok(vim.treesitter.get_parser(0, "lua", { error = false }) ~= nil, "parser treesitter lua")
t.ok(vim.treesitter.highlighter.active[vim.api.nvim_get_current_buf()] ~= nil, "coloration treesitter active")

local buf_maps = {}
for _, mode in ipairs({ "n", "x", "i" }) do
  for _, m in ipairs(vim.api.nvim_buf_get_keymap(0, mode)) do
    buf_maps[mode .. vim.fn.keytrans(m.lhsraw):gsub("^<Space>", "<leader>")] = true
  end
end
for _, k in ipairs({
  "ngd", "ngr", "ngI", "ngy", "ngD", "nK", "ngK", "i<C-K>",
  "n<leader>ca", "x<leader>ca", "n<leader>cA", "n<leader>co", "n<leader>cr", "n<leader>cR",
  "n<leader>cl", "n]]", "n[[", "n<M-n>", "n<M-p>",
  "n]f", "n[f", "n]F", "n[F",
}) do
  t.ok(buf_maps[k], "raccourci LSP/buffer " .. k)
end

local global = {}
for _, m in ipairs(vim.api.nvim_get_keymap("n")) do
  global[m.lhs] = true
end
for _, k in ipairs({ "grn", "gra", "grr", "gri" }) do
  t.ok(global[k], "raccourci natif " .. k)
end

t.ok(package.loaded["blink.cmp"] ~= nil, "blink.cmp chargé")
local lib = vim.tbl_get(vim.lsp.config.lua_ls, "settings", "Lua", "workspace", "library") or {}
t.ok(vim.tbl_contains(lib, vim.env.VIMRUNTIME), "lua_ls connaît $VIMRUNTIME")
t.ok(t.wait(function()
  return #vim.diagnostic.get(0) > 0
end, 30000), "diagnostic sur la globale inconnue")

t.finish()
