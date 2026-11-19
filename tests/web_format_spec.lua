-- Prettier seulement si le projet l'a configuré (JS/TS, JSON, YAML, Markdown), YAML à 2
-- espaces quoi qu'il arrive, markdownlint, CSS/HTML.
local t = require("helpers")
local web = require("manu.lang.web")
local cfg = vim.fn.stdpath("config")

local css_enabled, html_enabled = vim.lsp.is_enabled("cssls"), vim.lsp.is_enabled("html")

-- Ce test porte sur le formatage : pas de serveurs LSP (ils réagiraient aux buffers ouverts
-- et fermés à la chaîne par des erreurs « No Project » sans rapport).
vim.lsp.enable({ "vtsls", "vue_ls", "eslint", "cssls", "html", "jsonls", "yamlls" }, false)

t.ok(t.wait(function()
  return vim.fn.executable("prettier") == 1
end, 120000), "prettier disponible (Mason)")

-- Hors de la config (qui a son propre .markdownlint-cli2.jsonc).
local tmp = vim.fn.tempname() .. "-webformat"
vim.fn.delete(tmp, "rf")
local function mk(name, files)
  local dir = tmp .. "/" .. name
  for path, lines in pairs(files) do
    vim.fn.mkdir(vim.fs.dirname(dir .. "/" .. path), "p")
    vim.fn.writefile(lines, dir .. "/" .. path)
  end
  return vim.uv.fs_realpath(dir)
end

local ts = { "const a = 1;", "export default a;" }
local json = { '{"a":1,', '   "b":[1,2]}' }
local yaml = { "a:", "    b: 1", "    c:", "        - x" }

local with = mk("with", {
  ["package.json"] = { '{ "name": "w" }' },
  [".prettierrc"] = { '{ "semi": false, "tabWidth": 4 }' },
  ["a.ts"] = ts, ["a.json"] = json, ["a.yaml"] = yaml,
})
local without = mk("without", {
  ["package.json"] = { '{ "name": "wo" }' },
  ["a.ts"] = ts, ["a.json"] = json, ["a.yaml"] = yaml, ["a.md"] = { "# Titre", "texte  " },
})
local pkgkey = mk("pkgkey", { ["package.json"] = { '{ "name": "k", "prettier": { "semi": false } }' } })

local function save(path)
  vim.cmd("edit! " .. path)
  vim.cmd("write")
  local lines = vim.fn.readfile(path)
  vim.cmd("bwipeout!")
  return lines
end

t.eq(save(with .. "/a.ts"), { "const a = 1", "export default a" }, "TS : Prettier du projet (semi: false)")
local j = save(with .. "/a.json")
t.ok(not vim.deep_equal(j, json), "JSON reformaté avec config Prettier")
t.eq(save(with .. "/a.yaml"), { "a:", "  b: 1", "  c:", "    - x" }, "YAML : 2 espaces malgré tabWidth 4")
t.eq(save(without .. "/a.ts"), ts, "sans config Prettier : TS inchangé")
t.eq(save(without .. "/a.json"), json, "sans config Prettier : JSON inchangé")
t.eq(save(without .. "/a.yaml"), yaml, "sans config Prettier : YAML inchangé")
t.eq(save(without .. "/a.md"), { "# Titre", "texte  " }, "sans config : Markdown inchangé")
t.ok(web.has_prettier_config(pkgkey), "clé « prettier » du package.json reconnue")
t.ok(not web.has_prettier_config(without), "pas de config → faux")

-- markdownlint, CSS, HTML
local mdl = require("lint").linters.markdownlint_manu
t.eq(mdl.args, { "--config", cfg .. "/.markdownlint-cli2.jsonc", "-" }, "markdownlint avec la config de neovimanu")
t.eq(require("lint").linters_by_ft.markdown, { "markdownlint_manu" }, "markdownlint actif en Markdown")
t.ok(css_enabled, "cssls activé")
t.ok(html_enabled, "html activé")

vim.cmd("edit " .. without .. "/a.md")
local maps = {}
for _, m in ipairs(vim.api.nvim_buf_get_keymap(0, "n")) do
  maps[vim.fn.keytrans(m.lhsraw):gsub("^<Space>", "<leader>")] = true
end
for _, k in ipairs({ "<leader>mf", "<leader>ml", "<leader>mc", "<leader>ma" }) do
  t.ok(maps[k], "raccourci Markdown " .. k)
end

t.finish()
