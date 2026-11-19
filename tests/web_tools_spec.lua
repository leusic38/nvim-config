-- package.json (package-info), npm/yarn dans le conteneur Node, snippets JS.
local t = require("helpers")
local project = require("manu.project")
local web = require("manu.lang.web")
local cfg = vim.fn.stdpath("config")
local fixture = vim.uv.fs_realpath(cfg .. "/tests/fixtures/web")

local function maps()
  local m = {}
  for _, k in ipairs(vim.api.nvim_buf_get_keymap(0, "n")) do
    m[vim.fn.keytrans(k.lhsraw):gsub("^<Space>", "<leader>")] = true
  end
  return m
end

vim.cmd("edit " .. fixture .. "/package.json")
t.ok(package.loaded["package-info"] ~= nil, "package-info chargé")
local m = maps()
for _, k in ipairs({ "<leader>jps", "<leader>jpc", "<leader>jpt", "<leader>jpu", "<leader>jpd", "<leader>jpi", "<leader>jpv" }) do
  t.ok(m[k], "package.json : " .. k)
end

vim.cmd("edit " .. fixture .. "/src/a.ts")
m = maps()
for _, k in ipairs({
  "<leader>jni", "<leader>jnr", "<leader>jnt", "<leader>jnb", "<leader>jnd",
  "<leader>yi", "<leader>yr", "<leader>yt", "<leader>yb", "<leader>yd",
  "<leader>jc", "<leader>jf", "<leader>ja", "<leader>jtc", "<leader>jti",
  "<leader>jcl", "<leader>jce", "<leader>jcw", "<leader>jci",
}) do
  t.ok(m[k], "JS : " .. k)
end

-- yarn dans le conteneur Node (php + nvm) quand le projet en a un.
local tmp = vim.fn.tempname() .. "-webtools"
vim.fn.mkdir(tmp .. "/.nvim", "p")
vim.fn.writefile({ "{}" }, tmp .. "/package.json")
vim.fn.writefile({ 'return { service = "php", container_root = "/var/app/x" }' }, tmp .. "/.nvim/docker.lua")
vim.fn.writefile({ "" }, tmp .. "/a.js")
vim.cmd("edit " .. tmp .. "/a.js")
local probe, running = project._probe_node, project.container_running
project._probe_node = function()
  return { setup = '. "$NVM_DIR/nvm.sh" >/dev/null' }
end
project.container_running = function()
  return true
end
local term = require("manu.terminal")
local run = term.run
local captured
term.run = function(argv)
  captured = argv
end
web.run(0, { "yarn", "install" })
term.run = run
project._probe_node, project.container_running = probe, running
t.eq(captured, {
  "docker", "compose", "exec", "-T", "-w", "/var/app/x", "php",
  "bash", "-c", '. "$NVM_DIR/nvm.sh" >/dev/null && exec "$@"', "manu", "yarn", "install",
}, "yarn install dans le conteneur, nvm chargé")

t.finish()
