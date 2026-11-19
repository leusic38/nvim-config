-- args: tests/fixtures/web/src/App.vue
-- Vue (vue_ls + vtsls en mode hybride) et ESLint (corrections à l'enregistrement, qui
-- respectent <leader>uf/uF, et ne bloquent pas un projet sans node_modules).
local t = require("helpers")
local cfg = vim.fn.stdpath("config")

t.eq(vim.bo.filetype, "vue", "filetype vue")
t.ok(t.wait(function()
  return vim.treesitter.get_parser(0, "vue", { error = false }) ~= nil
end, 60000), "parser vue")
t.ok(t.wait(function()
  return #vim.lsp.get_clients({ bufnr = 0, name = "vue_ls" }) == 1
end, 120000), "vue_ls attaché")
t.ok(t.wait(function()
  return #vim.lsp.get_clients({ bufnr = 0, name = "vtsls" }) == 1
end, 120000), "vtsls attaché au .vue")
local plugin = vim.lsp.config.vtsls.settings.vtsls.tsserver.globalPlugins[1]
t.eq(plugin.name, "@vue/typescript-plugin", "plugin TypeScript de Vue")
t.ok(vim.uv.fs_stat(plugin.location) ~= nil, "plugin Vue présent sur le disque (" .. plugin.location .. ")")

local function maps()
  local m = {}
  for _, k in ipairs(vim.api.nvim_buf_get_keymap(0, "n")) do
    m[vim.fn.keytrans(k.lhsraw):gsub("^<Space>", "<leader>")] = k
  end
  return m
end
for _, k in ipairs({ "<leader>vc", "<leader>vr", "<leader>vs", "<leader>v3", "<leader>jle" }) do
  t.ok(maps()[k], "raccourci Vue " .. k)
end

-- gd depuis le <script> du .vue vers a.ts (vtsls + plugin Vue).
vim.fn.search([[greet(]])
t.ok(t.wait(function()
  local r = vim.lsp.buf_request_sync(0, "textDocument/definition", vim.lsp.util.make_position_params(0, "utf-16"), 3000)
  return vim.inspect(r or {}):find("a%.ts") ~= nil
end, 60000), "définition depuis le .vue trouvée dans a.ts")

-- ESLint
t.eq(vim.lsp.config.eslint.settings.workingDirectory.mode, "auto", "eslint : workingDirectory auto")
local noprettier = vim.uv.fs_realpath(cfg .. "/tests/fixtures/web-noprettier")
vim.cmd("edit " .. noprettier .. "/src/a.js")
local before = vim.fn.readfile(noprettier .. "/src/a.js")
-- Laisser à eslint le temps de démarrer (il n'a pas de node_modules ici).
vim.wait(3000)
local start = vim.uv.hrtime()
vim.v.errmsg = ""
vim.cmd("write")
local took = (vim.uv.hrtime() - start) / 1e9
t.ok(took < 3, ("enregistrement sans blocage (%.1f s)"):format(took))
t.eq(vim.v.errmsg, "", "enregistrement sans erreur")
t.eq(vim.fn.readfile(noprettier .. "/src/a.js"), before, "sans ESLint installé : fichier inchangé")

-- <leader>uF coupe la correction ESLint du buffer.
local web = require("manu.lang.web")
local called = 0
local fix = web.eslint_fix
web.eslint_fix = function()
  called = called + 1
end
vim.b.autoformat = false
vim.cmd("write")
web.eslint_fix = fix
vim.b.autoformat = nil
t.eq(called, 0, "formatage coupé : pas de correction ESLint")

t.finish()
