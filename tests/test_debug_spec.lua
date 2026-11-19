-- Tests (neotest : PHPUnit, Pest, dans le conteneur via bin/docker-phpunit) et phpactor.
-- La partie débogage est ajoutée par la Task 7.
local t = require("helpers")
local project = require("manu.project")
local cfg = vim.fn.stdpath("config")
local fixture = vim.uv.fs_realpath(cfg .. "/tests/fixtures/symfony")

t.ok(package.loaded.neotest ~= nil, "neotest chargé")
local names = vim.tbl_map(function(a)
  return a.name
end, require("manu.test").adapters())
t.ok(vim.tbl_contains(names, "neotest-phpunit"), "adaptateur PHPUnit")
t.ok(vim.tbl_contains(names, "neotest-pest"), "adaptateur Pest")

-- Commande PHPUnit : hôte (fixture) et conteneur.
vim.cmd("edit " .. fixture .. "/tests/GreeterTest.php")
local report = table.concat(project.describe(), "\n")
t.ok(report:find(fixture .. "/vendor/bin/phpunit", 1, true), "phpunit du projet sur l'hôte (" .. report .. ")")

local tmp = cfg .. "/tests/tmp/phpunit"
vim.fn.delete(tmp, "rf")
vim.fn.mkdir(tmp .. "/proj/.nvim", "p")
vim.fn.mkdir(tmp .. "/proj/tests", "p")
vim.fn.mkdir(tmp .. "/proj/bin", "p")
vim.fn.mkdir(tmp .. "/fakebin", "p")
local proj = vim.uv.fs_realpath(tmp .. "/proj")
vim.fn.writefile({ '{ "config": { "bin-dir": "bin" } }' }, proj .. "/composer.json")
vim.fn.writefile({ "" }, proj .. "/bin/phpunit")
vim.fn.writefile({ 'return { service = "php", container_root = "/var/app/x" }' }, proj .. "/.nvim/docker.lua")
vim.fn.writefile({ "<?php" }, proj .. "/tests/ATest.php")
vim.cmd("edit " .. proj .. "/tests/ATest.php")
local running = project.container_running
project.container_running = function()
  return true
end
local described = table.concat(project.describe(), "\n")
project.container_running = running
t.ok(described:find(cfg .. "/bin/docker-phpunit " .. proj .. " php /var/app/x bin/phpunit", 1, true), "dockerisé : bin/docker-phpunit avec le phpunit du projet")

-- bin/docker-phpunit avec un faux docker : arguments traduits, rapport rapatrié.
vim.fn.writefile({
  "#!/bin/sh",
  'echo "$@" > "' .. tmp .. '/docker-args"',
  'for a in "$@"; do case "$a" in --log-junit=*) f=${a#--log-junit=}; echo "<testsuite file=\\"$f\\"/>" > "var/$(basename "$f")";; esac; done',
  "exit 3",
}, tmp .. "/fakebin/docker")
vim.uv.fs_chmod(tmp .. "/fakebin/docker", tonumber("755", 8))
local res = vim.system({
  cfg .. "/bin/docker-phpunit", proj, "php", "/var/app/x", "bin/phpunit",
  "--log-junit=" .. tmp .. "/report.xml", proj .. "/tests/ATest.php", "--filter", "testA",
}, { env = { PATH = tmp .. "/fakebin:" .. vim.env.PATH }, text = true }):wait()
t.eq(res.code, 3, "code de sortie de l'outil rendu")
local args = vim.fn.readfile(tmp .. "/docker-args")[1] or ""
t.ok(args:find("compose exec %-T %-w /var/app/x php bin/phpunit"), "docker compose exec dans le conteneur")
t.ok(args:find("/var/app/x/tests/ATest.php", 1, true), "fichier de test traduit")
t.ok(args:find("--log-junit=/var/app/x/var/neotest-junit-", 1, true), "rapport écrit dans var/ du projet")
t.ok(args:find("--filter testA", 1, true), "--filter intact")
local rep = table.concat(vim.fn.readfile(tmp .. "/report.xml"), "")
t.ok(rep:find(proj .. "/var/neotest-junit-", 1, true), "rapport rapatrié, chemins retraduits vers l'hôte")

-- phpactor
t.eq(vim.fn.exists(":PhpactorContextMenu"), 2, ":PhpactorContextMenu existe")
vim.cmd("edit " .. fixture .. "/src/Service/Greeter.php")
local maps = {}
for _, m in ipairs(vim.api.nvim_buf_get_keymap(0, "n")) do
  maps[vim.fn.keytrans(m.lhsraw):gsub("^<Space>", "<leader>")] = true
end
for _, k in ipairs({
  "<leader>pta", "<leader>ptn", "<leader>pts", "<leader>pto",
  "<leader>pm", "<leader>pn", "<leader>pE", "<leader>pp", "<leader>pT", "<leader>pi",
  "<leader>pv", "<leader>pc", "<leader>pf", "<leader>pe", "<leader>pr", "<leader>ps",
}) do
  t.ok(maps[k], "raccourci " .. k)
end

t.finish()
