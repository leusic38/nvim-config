-- PHP : php-cs-fixer et PHPStan seulement si le projet a leur config ; dans le conteneur
-- quand le projet en déclare un ; rien sur l'hôte si ce conteneur est arrêté.
local t = require("helpers")
local project = require("manu.project")

local tmp = vim.fn.stdpath("config") .. "/tests/tmp/phpformat"
vim.fn.delete(tmp, "rf")
local function mk(name, files)
  local dir = tmp .. "/" .. name
  for path, lines in pairs(files) do
    vim.fn.mkdir(vim.fs.dirname(dir .. "/" .. path), "p")
    vim.fn.writefile(lines, dir .. "/" .. path)
  end
  return vim.uv.fs_realpath(dir)
end

local ugly = { "<?php", "class A", "{", "public function f() { return 1; }", "}" }
local cfg = { "<?php", "return (new PhpCsFixer\\Config())->setRules(['@PSR12' => true]);" }

t.ok(t.wait(function()
  return vim.fn.executable("php-cs-fixer") == 1
end, 120000), "php-cs-fixer disponible (Mason)")

local a = mk("a", { ["composer.json"] = { "{}" }, [".php-cs-fixer.dist.php"] = cfg, ["src/A.php"] = ugly })
local b = mk("b", { ["composer.json"] = { "{}" }, ["src/A.php"] = ugly })

local function save(path)
  vim.cmd("edit! " .. path)
  vim.cmd("write")
  local lines = vim.fn.readfile(path)
  vim.cmd("bwipeout!")
  return lines
end

local formatted = save(a .. "/src/A.php")
t.ok(not vim.deep_equal(formatted, ugly), "projet avec .php-cs-fixer.dist.php : reformaté")
t.ok(vim.tbl_contains(formatted, "    public function f()"), "PSR-12 appliqué (" .. vim.inspect(formatted) .. ")")
t.eq(save(b .. "/src/A.php"), ugly, "projet sans config : inchangé")

-- Conteneur : arguments traduits, binaire du projet (bin-dir).
local c = mk("c", {
  ["composer.json"] = { '{ "config": { "bin-dir": "bin" } }' },
  [".nvim/docker.lua"] = { 'return { service = "php", container_root = "/var/app/x" }' },
  [".php-cs-fixer.dist.php"] = cfg,
  ["phpstan.dist.neon"] = { "parameters:", "  level: 1" },
  ["bin/php-cs-fixer"] = { "" },
  ["bin/phpstan"] = { "" },
  ["src/A.php"] = ugly,
})
vim.cmd("edit " .. c .. "/src/A.php")
local buf = vim.api.nvim_get_current_buf()
local running = project.container_running
project.container_running = function()
  return true
end
local f = require("conform").formatters.php_cs_fixer_project
local ctx = { buf = buf, filename = c .. "/src/A.php", dirname = c .. "/src" }
t.eq(f.command(f, ctx), "docker", "php-cs-fixer : commande docker")
t.eq(f.args(f, ctx), {
  "compose", "exec", "-T", "-w", "/var/app/x", "php", "bin/php-cs-fixer", "fix", "--quiet",
  "--config=/var/app/x/.php-cs-fixer.dist.php", "/var/app/x/src/A.php",
}, "php-cs-fixer : chemins conteneur et binaire du projet")
local linter = require("lint").linters.phpstan_project()
t.eq(linter.cmd, "docker", "phpstan : commande docker")
t.ok(vim.tbl_contains(linter.args, "bin/phpstan") and vim.tbl_contains(linter.args, "/var/app/x/src/A.php"), "phpstan : binaire du projet, chemin conteneur")
-- Sortie PHPStan (chemins conteneur) ramenée sur le buffer.
local out = vim.json.encode({ files = { ["/var/app/x/src/A.php"] = { messages = { { line = 3, message = "Oups", identifier = "x.y" } } } } })
local diags = linter.parser(out, buf)
t.eq(#diags, 1, "phpstan : diagnostic du conteneur rattaché au fichier hôte")
t.eq(diags[1].lnum, 2, "phpstan : ligne")
local ml = require("manu.lint")
t.eq(ml.names_for(buf, "BufWritePost"), { "phpstan_project" }, "phpstan à l'enregistrement")
t.eq(ml.names_for(buf, "InsertLeave"), {}, "pas de phpstan en quittant l'insertion")
t.eq(ml.names_for(buf, "BufReadPost"), {}, "pas de phpstan à l'ouverture")

-- Conteneur arrêté : rien sur l'hôte.
project.container_running = function()
  return false
end
local notify = vim.notify
vim.notify = function() end
t.ok(not f.condition(f, ctx), "conteneur arrêté : php-cs-fixer ne tourne pas")
t.eq(ml.names_for(buf, "BufWritePost"), {}, "conteneur arrêté : phpstan ne tourne pas")
vim.notify = notify
project.container_running = running

-- Sans phpstan.neon : pas d'analyse.
vim.cmd("edit " .. b .. "/src/A.php")
t.eq(ml.names_for(0, "BufWritePost"), {}, "sans phpstan.neon : pas d'analyse")

-- Raccourcis buffer PHP
local maps = {}
for _, m in ipairs(vim.api.nvim_buf_get_keymap(0, "n")) do
  maps[vim.fn.keytrans(m.lhsraw):gsub("^<Space>", "<leader>")] = true
end
for _, k in ipairs({ "<leader>plf", "<leader>plc", "<leader>pll" }) do
  t.ok(maps[k], "raccourci " .. k)
end
t.finish()
