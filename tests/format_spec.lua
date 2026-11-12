-- Formatage à l'enregistrement : seulement si le projet a la config du formateur,
-- et pas quand il est coupé pour le buffer.
local t = require("helpers")
local format = require("manu.format")

local tmp = vim.fn.stdpath("config") .. "/tests/tmp/format"
vim.fn.delete(tmp, "rf")
local a, b = tmp .. "/projet_a", tmp .. "/projet_b"
vim.fn.mkdir(a, "p")
vim.fn.mkdir(b, "p")
vim.fn.writefile({ 'indent_type = "Spaces"', "indent_width = 2" }, a .. "/stylua.toml")

local ugly = { "local x = {", "        a = 1,", "}" }
local pretty = { "local x = {", "  a = 1,", "}" }

t.ok(t.wait(function()
  return vim.fn.executable("stylua") == 1
end, 120000), "stylua installé (Mason)")

local function save_and_read(path, before)
  vim.fn.writefile(ugly, path)
  vim.cmd("edit! " .. path)
  if before then
    before()
  end
  vim.cmd("write")
  local lines = vim.fn.readfile(path)
  vim.cmd("bwipeout!")
  return lines
end

t.eq(save_and_read(a .. "/a.lua"), pretty, "projet avec stylua.toml : reformaté à l'enregistrement")
t.eq(save_and_read(b .. "/b.lua"), ugly, "projet sans stylua.toml : inchangé")
t.eq(save_and_read(a .. "/c.lua", function()
  vim.b.autoformat = false
end), ugly, "formatage coupé pour le buffer : inchangé")
t.eq(save_and_read(a .. "/d.lua", function()
  vim.g.autoformat = false
end), ugly, "formatage coupé globalement : inchangé")
vim.g.autoformat = true

vim.cmd("edit " .. a .. "/a.lua")
t.ok(format.project_has({ "stylua.toml" }, 0), "project_has vrai dans le projet A")
vim.cmd("edit " .. b .. "/b.lua")
t.ok(not format.project_has({ "stylua.toml" }, 0), "project_has faux dans le projet B")

t.ok(package.loaded.lint ~= nil, "nvim-lint chargé")
t.finish()
