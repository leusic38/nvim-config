-- manu.project : racine, framework, conteneur (jamais de repli hôte), binaires du projet.
local t = require("helpers")
local project = require("manu.project")

local cfg = vim.fn.stdpath("config")
local fixture = vim.uv.fs_realpath(cfg .. "/tests/fixtures/symfony")

vim.cmd("edit " .. fixture .. "/src/Service/Greeter.php")
t.eq(project.root(0), fixture, "racine = dossier du composer.json")
t.eq(project.framework(0), "symfony", "framework symfony (bin/console)")

local tmp = cfg .. "/tests/tmp/project"
vim.fn.delete(tmp, "rf")
local function mkproject(name, files)
  local dir = tmp .. "/" .. name
  vim.fn.mkdir(dir, "p")
  for path, lines in pairs(files) do
    vim.fn.mkdir(vim.fs.dirname(dir .. "/" .. path), "p")
    vim.fn.writefile(lines, dir .. "/" .. path)
  end
  return vim.uv.fs_realpath(dir)
end

local laravel = mkproject("laravel", { ["composer.json"] = { "{}" }, ["artisan"] = { "" }, ["app/A.php"] = { "" } })
vim.cmd("edit " .. laravel .. "/app/A.php")
t.eq(project.framework(0), "laravel", "framework laravel (artisan)")
local plain = mkproject("plain", { ["composer.json"] = { "{}" }, ["src/A.php"] = { "" } })
vim.cmd("edit " .. plain .. "/src/A.php")
t.eq(project.framework(0), nil, "pas de framework")

-- Conteneur déclaré
local docker = mkproject("docker", {
  ["composer.json"] = { '{ "config": { "bin-dir": "bin" } }' },
  [".nvim/docker.lua"] = { 'return { service = "php", container_root = "/var/app/x", node = { service = "node", container_root = "/app" } }' },
  ["bin/phpstan"] = { "" },
  ["src/A.php"] = { "" },
})
t.eq(project.docker(docker), { service = "php", container_root = "/var/app/x" }, "docker.lua lu (php)")
-- Node dans le conteneur PHP (sonde remplacée) : via nvm, ou absent, ou node = false.
local probe = project._probe_node
project._probe_node = function()
  return { setup = '. "$NVM_DIR/nvm.sh" >/dev/null' }
end
local auto = mkproject("autonode", { [".nvim/docker.lua"] = { 'return { service = "php", container_root = "/v" }' } })
t.eq(project.docker(auto, "node"), { service = "php", container_root = "/v", setup = '. "$NVM_DIR/nvm.sh" >/dev/null' }, "node détecté dans le conteneur php (nvm)")
local orig_running = project.container_running
project.container_running = function()
  return true
end
t.eq(project.cmd(auto, { "node_modules/.bin/jest" }, "node"), {
  "docker", "compose", "exec", "-T", "-w", "/v", "php", "bash", "-c", '. "$NVM_DIR/nvm.sh" >/dev/null && exec "$@"', "manu", "node_modules/.bin/jest",
}, "commande node via nvm, arguments intacts")
project.container_running = orig_running
project._probe_node = function()
  return false
end
t.eq(project.docker(auto, "node"), nil, "pas de node dans le conteneur → hôte")
local off = mkproject("nodeoff", { [".nvim/docker.lua"] = { 'return { service = "php", container_root = "/v", node = false }' } })
t.eq(project.docker(off, "node"), nil, "node = false → hôte")
project._probe_node = probe
t.eq(project.docker(docker, "node"), { service = "node", container_root = "/app" }, "docker.lua lu (node)")
t.eq(project.docker(plain), nil, "pas de docker.lua → nil")
local bad = mkproject("bad", { ["composer.json"] = { "{}" }, [".nvim/docker.lua"] = { "return 42" } })
t.eq(project.docker(bad), nil, "docker.lua invalide → nil sans erreur")

local d = project.docker(docker)
t.eq(project.to_container(docker .. "/src/A.php", docker, d), "/var/app/x/src/A.php", "chemin hôte → conteneur")
t.eq(project.to_host("/var/app/x/src/A.php", docker, d), docker .. "/src/A.php", "chemin conteneur → hôte")

-- Commande : conteneur en marche / arrêté / pas de conteneur.
local running = project.container_running
local notify = vim.notify
local warnings = {}
vim.notify = function(msg)
  table.insert(warnings, msg)
end
project.container_running = function()
  return true
end
t.eq(project.cmd(docker, { "bin/phpunit" }), { "docker", "compose", "exec", "-T", "-w", "/var/app/x", "php", "bin/phpunit" }, "conteneur en marche")
t.eq(project.cmd(docker, { "x" }, "node"), { "docker", "compose", "exec", "-T", "-w", "/app", "node", "x" }, "conteneur node")
project.container_running = function()
  return false
end
local c, msg = project.cmd(docker, { "bin/phpunit" })
t.eq(c, nil, "conteneur arrêté : pas de repli sur l'hôte")
t.ok(msg and msg:find("docker compose up %-d php"), "message pour démarrer le conteneur")
project.cmd(docker, { "bin/phpunit" })
vim.wait(100)
t.eq(#warnings, 1, "un seul avertissement par session")
project.container_running = running
vim.notify = notify
t.eq(project.cmd(plain, { "vendor/bin/phpunit" }), { "vendor/bin/phpunit" }, "sans conteneur : sur l'hôte")

-- Binaires du projet
t.eq(project.bin(docker, "phpstan"), "bin/phpstan", "bin-dir du composer.json")
t.eq(project.bin(docker, "phpunit"), nil, "binaire absent → nil")
local vendor = mkproject("vendor", { ["composer.json"] = { "{}" }, ["vendor/bin/phpstan"] = { "" } })
t.eq(project.bin(vendor, "phpstan"), "vendor/bin/phpstan", "défaut vendor/bin")

-- :Projet
vim.cmd("edit " .. fixture .. "/src/Service/Greeter.php")
local lines = project.describe()
t.ok(lines[1]:find("fixtures/symfony", 1, true), "describe : racine")
t.ok(pcall(vim.cmd, "Projet"), ":Projet sans erreur")

t.finish()
