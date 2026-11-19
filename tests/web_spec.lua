-- args: tests/fixtures/web/src/b.ts
-- TypeScript : vtsls attaché, gd entre fichiers, raccourcis vtsls (gD source, gR…), indices.
local t = require("helpers")

t.eq(vim.bo.filetype, "typescript", "filetype typescript")
t.ok(t.wait(function()
  return vim.treesitter.get_parser(0, "typescript", { error = false }) ~= nil
end, 60000), "parser typescript")
t.ok(t.wait(function()
  return #vim.lsp.get_clients({ bufnr = 0, name = "vtsls" }) == 1
end, 120000), "vtsls attaché")

local function maps()
  local m = {}
  for _, k in ipairs(vim.api.nvim_buf_get_keymap(0, "n")) do
    m[vim.fn.keytrans(k.lhsraw):gsub("^<Space>", "<leader>")] = k
  end
  return m
end
t.ok(t.wait(function()
  return maps()["gR"] ~= nil
end, 10000), "raccourcis vtsls posés")
local m = maps()
t.eq(m["gD"] and m["gD"].desc, "Aller à la définition source (TS)", "gD = définition source (vtsls l'emporte sur lsp.lua)")
for _, k in ipairs({ "gR", "<leader>cM", "<leader>cD", "<leader>cV", "<leader>jlo", "<leader>jls", "<leader>jlu", "<leader>jlg", "<leader>jlr", "<leader>jla" }) do
  t.ok(m[k], "raccourci " .. k)
end

local settings = vim.lsp.config.vtsls.settings
t.eq(settings.typescript.inlayHints.parameterNames.enabled, "literals", "indices TS : littéraux")
t.eq(settings.javascript.inlayHints.parameterNames.enabled, "all", "indices JS : tous")

-- gd sur greet → a.ts. Tant que le projet TS se charge, vtsls répond par l'import local :
-- attendre une réponse qui vise a.ts.
vim.fn.search([[greet(]])
t.wait(function()
  local r = vim.lsp.buf_request_sync(0, "textDocument/definition", vim.lsp.util.make_position_params(0, "utf-16"), 3000)
  return vim.inspect(r or {}):find("a%.ts") ~= nil
end, 60000)
m["gd"].callback()
t.ok(t.wait(function()
  return vim.api.nvim_buf_get_name(0):match("src/a%.ts$") ~= nil
end, 10000), "gd ouvre src/a.ts")

t.finish()
