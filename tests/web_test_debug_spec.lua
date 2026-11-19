-- Tests JS (Jest, Vitest : outil du projet, conteneur Node via bin/docker-test) et débogage
-- Node (js-debug-adapter).
local t = require("helpers")
local project = require("manu.project")
local web = require("manu.lang.web")
local cfg = vim.fn.stdpath("config")

local names = vim.tbl_map(function(a)
  return a.name
end, require("manu.test").adapters())
t.ok(vim.tbl_contains(names, "neotest-jest"), "adaptateur Jest")
t.ok(vim.tbl_contains(names, "neotest-vitest"), "adaptateur Vitest")

local tmp = vim.fn.tempname() .. "-webtest"
local function mk(name, files)
  local dir = tmp .. "/" .. name
  for path, lines in pairs(files) do
    vim.fn.mkdir(vim.fs.dirname(dir .. "/" .. path), "p")
    vim.fn.writefile(lines, dir .. "/" .. path)
  end
  return vim.uv.fs_realpath(dir)
end

-- Hôte : node_modules/.bin/jest du projet.
local host = mk("host", { ["package.json"] = { "{}" }, ["node_modules/.bin/jest"] = { "" }, ["src/a.test.js"] = { "" } })
t.eq(web.test_command("jest", host .. "/src/a.test.js"), host .. "/node_modules/.bin/jest", "Jest du projet sur l'hôte")

-- Conteneur Node via nvm (cas de lama).
local dock = mk("dock", {
  ["package.json"] = { "{}" },
  [".nvim/docker.lua"] = { 'return { service = "php", container_root = "/var/app/x" }' },
  ["node_modules/.bin/jest"] = { "" },
  ["src/a.test.js"] = { "" },
})
local probe, running = project._probe_node, project.container_running
project._probe_node = function()
  return { setup = '. "$NVM_DIR/nvm.sh" >/dev/null' }
end
project.container_running = function()
  return true
end
t.eq(web.test_command("jest", dock .. "/src/a.test.js"),
  table.concat({ cfg .. "/bin/docker-test", dock, "php", "/var/app/x", "nvm", "node_modules/.bin/jest" }, " "),
  "Jest dans le conteneur php, nvm chargé")
project.container_running = function()
  return false
end
local notify = vim.notify
vim.notify = function() end
t.eq(web.test_command("jest", dock .. "/src/a.test.js"), "false", "conteneur arrêté : pas de repli hôte")
vim.notify = notify
project._probe_node, project.container_running = probe, running

-- bin/docker-test avec Jest : --outputFile rapatrié, nvm chargé dans le conteneur.
vim.fn.mkdir(tmp .. "/fakebin", "p")
vim.fn.writefile({
  "#!/bin/sh",
  'echo "$@" > "' .. tmp .. '/docker-args"',
  'for a in "$@"; do case "$a" in --outputFile=*) f=${a#--outputFile=}; echo "{\\"testResults\\":[{\\"name\\":\\"/var/app/x/src/a.test.js\\"}]}" > "var/$(basename "$f")";; esac; done',
}, tmp .. "/fakebin/docker")
vim.uv.fs_chmod(tmp .. "/fakebin/docker", tonumber("755", 8))
local res = vim.system({
  cfg .. "/bin/docker-test", dock, "php", "/var/app/x", "nvm", "node_modules/.bin/jest",
  "--json", "--outputFile=" .. tmp .. "/out.json", dock .. "/src/a.test.js",
}, { env = { PATH = tmp .. "/fakebin:" .. vim.env.PATH }, text = true }):wait()
t.eq(res.code, 0, "docker-test : code 0")
local args = vim.fn.readfile(tmp .. "/docker-args")[1] or ""
t.ok(args:find("bash %-c"), "nvm chargé (bash -c)")
t.ok(args:find("/var/app/x/src/a.test.js", 1, true), "fichier de test traduit")
t.ok(table.concat(vim.fn.readfile(tmp .. "/out.json"), ""):find(dock .. "/src/a.test.js", 1, true), "rapport JSON rapatrié, chemins hôte")

-- Débogage Node
local dap = require("dap")
t.eq(dap.adapters["pwa-node"].executable.command, "node", "adaptateur pwa-node")
t.ok(t.wait(function()
  return vim.fn.filereadable(dap.adapters["pwa-node"].executable.args[1]) == 1
end, 60000), "js-debug-adapter installé")
local cnames = vim.tbl_map(function(c)
  return c.name
end, dap.configurations.typescript or {})
for _, n in ipairs({ "Launch Node.js Program", "Attach to Node.js Process", "Debug Jest Tests" }) do
  t.ok(vim.tbl_contains(cnames, n), "configuration " .. n)
end

-- Raccourcis buffer
vim.cmd("edit " .. host .. "/src/a.test.js")
local maps = {}
for _, m in ipairs(vim.api.nvim_buf_get_keymap(0, "n")) do
  maps[vim.fn.keytrans(m.lhsraw):gsub("^<Space>", "<leader>")] = true
end
for _, k in ipairs({
  "<leader>jta", "<leader>jtn", "<leader>jts", "<leader>jto", "<leader>jtw",
  "<leader>jdb", "<leader>jdc", "<leader>jds", "<leader>jdi", "<leader>jdo", "<leader>jdr", "<leader>jdl",
}) do
  t.ok(maps[k], "raccourci " .. k)
end
t.finish()
