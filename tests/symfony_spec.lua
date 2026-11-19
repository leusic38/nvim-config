-- Symfony : symfony-lsp seulement sur une vraie appli, gd config → classe / template sans
-- serveur, raccourcis <leader>S… et Composer, console dans le conteneur.
local t = require("helpers")
local project = require("manu.project")
local cfg = vim.fn.stdpath("config")
local fixture = vim.uv.fs_realpath(cfg .. "/tests/fixtures/symfony")

-- root_dir de symfony_lsp
local root_dir = vim.lsp.config.symfony_lsp.root_dir
local function root_for(path)
  vim.cmd("edit " .. path)
  local got
  root_dir(vim.api.nvim_get_current_buf(), function(dir)
    got = dir
  end)
  return got
end
t.eq(root_for(fixture .. "/src/Service/Greeter.php"), fixture, "symfony_lsp : racine de l'appli Symfony")
t.eq(root_for(cfg .. "/init.lua"), nil, "symfony_lsp : pas d'attache hors appli Symfony")

local function buf_maps()
  local maps = {}
  for _, m in ipairs(vim.api.nvim_buf_get_keymap(0, "n")) do
    maps[vim.fn.keytrans(m.lhsraw):gsub("^<Space>", "<leader>")] = m
  end
  return maps
end

-- gd dans services.xml : PSR-4, sans serveur.
vim.cmd("edit " .. fixture .. "/config/services.xml")
local maps = buf_maps()
t.ok(maps["gd"] and maps["gd"].desc:find("^Symfony"), "gd Symfony dans services.xml")
vim.fn.search([[Greeter]])
maps["gd"].callback()
t.ok(vim.api.nvim_buf_get_name(0):match("src/Service/Greeter%.php$"), "gd : services.xml → Greeter.php")

-- gd dans un template : nom de template → fichier.
vim.cmd("edit " .. fixture .. "/templates/home/index.html.twig")
maps = buf_maps()
t.ok(maps["gd"], "gd Symfony dans un template")
vim.fn.search([[base\.html]])
maps["gd"].callback()
t.ok(vim.api.nvim_buf_get_name(0):match("templates/base%.html%.twig$"), "gd : extends → base.html.twig")

-- Hors appli Symfony : pas de gd Symfony.
local tmp = cfg .. "/tests/tmp/symfony"
vim.fn.mkdir(tmp, "p")
vim.fn.writefile({ "services:", "  web:", "    image: nginx" }, tmp .. "/docker-compose.yml")
vim.cmd("edit " .. tmp .. "/docker-compose.yml")
maps = buf_maps()
t.ok(not (maps["gd"] and (maps["gd"].desc or ""):find("^Symfony")), "pas de gd Symfony sur un docker-compose.yml")

-- Raccourcis sur php, xml, yaml, twig de l'appli
for _, f in ipairs({ "src/Service/Greeter.php", "config/services.xml", "config/services.yaml", "templates/base.html.twig" }) do
  vim.cmd("edit " .. fixture .. "/" .. f)
  maps = buf_maps()
  for _, k in ipairs({ "<leader>Si", "<leader>SR", "<leader>SE", "<leader>Sc", "<leader>Sm", "<leader>Sd", "<leader>Sr", "<leader>Ss", "<leader>Se" }) do
    t.ok(maps[k], f .. " : " .. k)
  end
end
vim.cmd("edit " .. fixture .. "/src/Service/Greeter.php")
maps = buf_maps()
for _, k in ipairs({ "<leader>Cu", "<leader>Ci", "<leader>Cd", "<leader>Cr" }) do
  t.ok(maps[k], "Composer " .. k)
end

-- Console : dans le conteneur quand le projet en déclare un.
local dock = cfg .. "/tests/tmp/symfony/dock"
vim.fn.mkdir(dock .. "/.nvim", "p")
vim.fn.mkdir(dock .. "/bin", "p")
vim.fn.writefile({ "{}" }, dock .. "/composer.json")
vim.fn.writefile({ "" }, dock .. "/bin/console")
vim.fn.writefile({ 'return { service = "php", container_root = "/var/app/x" }' }, dock .. "/.nvim/docker.lua")
vim.fn.writefile({ "<?php" }, dock .. "/A.php")
vim.cmd("edit " .. dock .. "/A.php")
local running = project.container_running
project.container_running = function()
  return true
end
local term = require("manu.terminal")
local run = term.run
local captured
term.run = function(argv)
  captured = argv
end
require("manu.lang.symfony")._run(0, { "php", "bin/console", "debug:router" })
term.run = run
project.container_running = running
t.eq(captured, { "docker", "compose", "exec", "-T", "-w", "/var/app/x", "php", "php", "bin/console", "debug:router" }, "console dans le conteneur")

t.finish()
