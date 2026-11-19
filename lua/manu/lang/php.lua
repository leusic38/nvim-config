-- Langage PHP (modèle de lang/lua.lua). Symfony (twig, xml, yaml de config, navigation,
-- console) : lang/symfony.lua.
--
-- Pas de php.vim (StanAngeloff) : Treesitter remplace la coloration Vim, et ses options ne
-- servaient qu'à couper les injections HTML/SQL de cette coloration.

local project = require("manu.project")

-- 2. Outils : Intelephense (serveur). Il reste sur l'hôte même si le projet est dockerisé :
--    il lit les fichiers (vendor/ compris), il n'exécute pas le code du projet.
--    php-cs-fixer et PHPStan de Mason : seulement pour un projet sans conteneur qui n'a pas
--    les siens (sinon : ceux du projet, dans le conteneur s'il y en a un).
require("manu.mason").ensure({ "intelephense", "php-cs-fixer", "phpstan" })

--- Version de PHP du projet (composer.json « require.php »), pour Intelephense.
local function php_version(root)
  local ok, lines = pcall(vim.fn.readfile, (root or "") .. "/composer.json")
  if ok then
    local ok2, composer = pcall(vim.json.decode, table.concat(lines, "\n"))
    local req = ok2 and type(composer) == "table" and vim.tbl_get(composer, "require", "php")
    local major, minor = type(req) == "string" and req:match("(%d+)%.(%d+)")
    if major then
      return ("%s.%s.0"):format(major, minor)
    end
  end
  return "8.2.0"
end

-- 3. Surcharge
vim.lsp.config("intelephense", {
  -- lama : vendor/ fait ~500 Mo, certains fichiers générés dépassent 1 Mo (défaut).
  settings = { intelephense = { files = { maxSize = 5000000 } } },
  before_init = function(_, config)
    config.settings.intelephense.environment = { phpVersion = php_version(config.root_dir) }
  end,
})

-- 4. Activation
vim.lsp.enable({ "intelephense" })

-- 5–6. Formateur (php-cs-fixer) et analyseur (PHPStan), voir plus bas.

-- 7. Parsers
require("manu.treesitter").install({ "php", "phpdoc", "html" })

require("manu.php_filters").setup()

project.report("php : serveur", function(bufnr)
  if vim.bo[bufnr].filetype ~= "php" then
    return nil
  end
  local c = vim.lsp.get_clients({ bufnr = bufnr, name = "intelephense" })[1]
  return c and ("intelephense (hôte), racine " .. vim.fn.fnamemodify(c.root_dir or "?", ":~")) or "intelephense non attaché"
end)

-- ─── Outils du projet : conteneur d'abord ───────────────────────────────────

local format = require("manu.format")

local CS_FIXER_CONFIGS = { ".php-cs-fixer.php", ".php-cs-fixer.dist.php" }
local PHPSTAN_CONFIGS = { "phpstan.neon", "phpstan.dist.neon", "phpstan.neon.dist" }

local function php_root(bufnr)
  return project.root(bufnr) or vim.fs.dirname(vim.api.nvim_buf_get_name(bufnr))
end

--- Commande d'un outil PHP pour ce buffer (voir manu.project.tool).
---@return string[]|nil argv, string root, table|nil docker
local function tool_cmd(bufnr, tool, args)
  local root = php_root(bufnr)
  local argv, docker = project.tool(root, tool, args)
  return argv, root, docker
end

-- php-cs-fixer : seulement si le projet a sa config (règle du formatage).
local function cs_fixer_argv(ctx)
  local config = vim.fs.find(CS_FIXER_CONFIGS, { path = ctx.dirname, upward = true })[1]
  if not config then
    return nil
  end
  return tool_cmd(ctx.buf, "php-cs-fixer", function(path)
    return { "fix", "--quiet", "--config=" .. path(config), path(ctx.filename) }
  end)
end

require("conform").formatters.php_cs_fixer_project = {
  condition = function(_, ctx)
    return format.project_has(CS_FIXER_CONFIGS, ctx.buf) and cs_fixer_argv(ctx) ~= nil
  end,
  command = function(_, ctx)
    return (cs_fixer_argv(ctx) or { "false" })[1]
  end,
  args = function(_, ctx)
    return vim.list_slice(cs_fixer_argv(ctx) or {}, 2)
  end,
  cwd = function(_, ctx)
    return php_root(ctx.buf)
  end,
  stdin = false,
}
require("conform").formatters_by_ft.php = { "php_cs_fixer_project" }

-- PHPStan : seulement si le projet a sa config, et à l'enregistrement seulement (lent).
local function phpstan_argv(bufnr)
  return tool_cmd(bufnr, "phpstan", function(path)
    return {
      "analyse",
      "--error-format=json",
      "--no-progress",
      "--memory-limit=1G",
      path(vim.api.nvim_buf_get_name(bufnr)),
    }
  end)
end

local lint = require("lint")
lint.linters.phpstan_project = function()
  local bufnr = vim.api.nvim_get_current_buf()
  local argv, root, docker = phpstan_argv(bufnr)
  argv = argv or { "false" }
  return {
    cmd = argv[1],
    args = vim.list_slice(argv, 2),
    cwd = root,
    stdin = false,
    append_fname = false,
    stream = "stdout",
    ignore_exitcode = true,
    parser = function(output)
      local items = {}
      local ok, decoded = pcall(vim.json.decode, output)
      if not ok or type(decoded) ~= "table" then
        return items
      end
      for file, file_errors in pairs(decoded.files or {}) do
        local host_file = docker and project.to_host(file, root, docker) or file
        if host_file == vim.api.nvim_buf_get_name(bufnr) then
          for _, e in ipairs(file_errors.messages or {}) do
            table.insert(items, {
              lnum = math.max((e.line or 1) - 1, 0),
              col = 0,
              message = e.message .. (e.identifier and (" [" .. e.identifier .. "]") or ""),
              severity = vim.diagnostic.severity.ERROR,
              source = "phpstan",
            })
          end
        end
      end
      return items
    end,
  }
end
lint.linters_by_ft.php = { "phpstan_project" }
require("manu.lint").configure("phpstan_project", {
  events = { "BufWritePost" },
  condition = function(bufnr)
    return vim.fs.root(bufnr, PHPSTAN_CONFIGS) ~= nil and (phpstan_argv(bufnr)) ~= nil
  end,
})

project.report("php : formateur", function(bufnr)
  if vim.bo[bufnr].filetype ~= "php" then
    return nil
  end
  if not format.project_has(CS_FIXER_CONFIGS, bufnr) then
    return "aucun (pas de .php-cs-fixer(.dist).php)"
  end
  local argv = cs_fixer_argv({ buf = bufnr, dirname = vim.fs.dirname(vim.api.nvim_buf_get_name(bufnr)), filename = vim.api.nvim_buf_get_name(bufnr) })
  return argv and table.concat(argv, " ") or "conteneur arrêté"
end)
project.report("php : analyse", function(bufnr)
  if vim.bo[bufnr].filetype ~= "php" then
    return nil
  end
  if not vim.fs.root(bufnr, PHPSTAN_CONFIGS) then
    return "aucune (pas de phpstan.neon)"
  end
  local argv = phpstan_argv(bufnr)
  return argv and table.concat(argv, " ") or "conteneur arrêté"
end)

-- ─── Raccourcis PHP (buffer, perso) ────────────────────────────────────────

vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("manu_php_keymaps", { clear = true }),
  pattern = "php",
  callback = function(ev)
    local function bmap(lhs, rhs, desc)
      vim.keymap.set("n", lhs, rhs, { buffer = ev.buf, desc = desc })
    end
    bmap("<leader>plf", function()
      vim.lsp.buf.format({ bufnr = ev.buf })
    end, "PHP : formater avec le LSP")
    bmap("<leader>plc", function()
      require("conform").format({ bufnr = ev.buf, formatters = { "php_cs_fixer_project" } })
    end, "PHP : formater avec php-cs-fixer")
    bmap("<leader>pll", function()
      if require("manu.lint").names_for(ev.buf, "BufWritePost")[1] then
        lint.try_lint("phpstan_project")
      else
        vim.notify("PHPStan : pas de phpstan.neon dans le projet, ou conteneur arrêté", vim.log.levels.WARN)
      end
    end, "PHP : lancer PHPStan")
  end,
})

-- ─── Tests : PHPUnit et Pest (neotest), dans le conteneur si dockerisé ──────

local config_dir = vim.fn.stdpath("config")

--- Commande PHPUnit / Pest pour neotest. Dockerisé : bin/docker-phpunit traduit les chemins
--- et rapatrie le rapport JUnit ; conteneur arrêté : échec explicite, pas de repli hôte.
---@param tool "phpunit"|"pest"
local function test_cmd(tool)
  return function()
    local root = project.root(vim.api.nvim_get_current_buf()) or project.root(nil) or assert(vim.uv.cwd())
    local rel = project.bin(root, tool) or (project.bin_dir(root) .. "/" .. tool)
    local docker = project.docker(root)
    if not docker then
      return { root .. "/" .. rel }
    end
    if not project.container_running(root, docker.service) then
      local msg = ("Conteneur %s arrêté : docker compose up -d %s"):format(docker.service, docker.service)
      return { "sh", "-c", "echo " .. vim.fn.shellescape(msg) .. " >&2; exit 1" }
    end
    return { config_dir .. "/bin/docker-phpunit", root, docker.service, docker.container_root, rel }
  end
end
local test = require("manu.test")
test.add_adapter(require("neotest-phpunit")({
  phpunit_cmd = test_cmd("phpunit"),
  root_files = { "phpunit.xml", "phpunit.xml.dist", "composer.json" },
  filter_dirs = { ".git", "node_modules", "vendor" },
}))
test.add_adapter(require("neotest-pest")({ pest_cmd = test_cmd("pest") }))

project.report("php : tests", function(bufnr)
  if vim.bo[bufnr].filetype ~= "php" then
    return nil
  end
  return table.concat(test_cmd("phpunit")(), " ")
end)

-- ─── phpactor ──────────────────────────────────────────────────────────────
-- Menu de refactoring PHP (nouvelle classe, import, transformation, copie de fichier) que
-- ni Intelephense ni refactoring.nvim ne couvrent. Le plugin embarque son binaire, à
-- compiler avec composer à l'installation et à chaque mise à jour (hook PackChanged).
require("manu.pack_hooks").register("phpactor", function(ev)
  if ev.data.kind == "install" or ev.data.kind == "update" then
    vim.notify("phpactor : composer install…")
    vim.system({
      "composer", "install", "--no-dev", "-o",
      "--ignore-platform-req=ext-iconv", "--ignore-platform-req=ext-mbstring",
    }, { cwd = ev.data.path }, function(res)
      vim.schedule(function()
        vim.notify("phpactor : composer install " .. (res.code == 0 and "terminé" or "en échec"),
          res.code == 0 and vim.log.levels.INFO or vim.log.levels.ERROR)
      end)
    end)
  end
end)
vim.pack.add({ "https://github.com/phpactor/phpactor" }, { confirm = false })

-- ─── Raccourcis PHP : tests, phpactor, snippets (buffer, perso) ─────────────

vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("manu_php_keymaps_more", { clear = true }),
  pattern = "php",
  callback = function(ev)
    local function bmap(lhs, rhs, desc)
      vim.keymap.set("n", lhs, rhs, { buffer = ev.buf, desc = desc })
    end
    local function neotest()
      return require("neotest")
    end
    bmap("<leader>pta", function()
      neotest().run.run(vim.fn.expand("%"))
    end, "PHP : tests du fichier")
    bmap("<leader>ptn", function()
      neotest().run.run()
    end, "PHP : test au curseur")
    bmap("<leader>pts", function()
      neotest().summary.toggle()
    end, "PHP : résumé des tests")
    bmap("<leader>pto", function()
      neotest().output.open({ enter = true })
    end, "PHP : sortie du test")

    bmap("<leader>pm", "<cmd>PhpactorContextMenu<cr>", "phpactor : menu contextuel")
    bmap("<leader>pn", "<cmd>PhpactorClassNew<cr>", "phpactor : nouvelle classe")
    bmap("<leader>pE", "<cmd>PhpactorClassExpand<cr>", "phpactor : nom complet de la classe")
    bmap("<leader>pp", "<cmd>PhpactorCopyFile<cr>", "phpactor : copier le fichier")
    bmap("<leader>pT", "<cmd>PhpactorTransform<cr>", "phpactor : transformer")
    bmap("<leader>pi", "<cmd>PhpactorImportClass<cr>", "phpactor : importer la classe")

    -- Snippets perso (repris tels quels de l'ancien php-keymaps.lua).
    bmap("<leader>pv", "i<?php<cr><cr>declare(strict_types=1);<cr><cr>", "PHP : en-tête strict_types")
    bmap("<leader>pc", "iclass <cr>{<cr><cr>}<esc>2k$F a", "PHP : modèle de classe")
    bmap("<leader>pf", "ipublic function ()<cr>{<cr><cr>}<esc>2k$F)i", "PHP : modèle de fonction")
    bmap("<leader>pe", "i#[Entity]<cr>class <cr>{<cr><cr>}<esc>2k$F a", "PHP : modèle d'entité Doctrine")
    bmap("<leader>pr", "iclass Repository extends ServiceEntityRepository<cr>{<cr><cr>}<esc>2k$FRa", "PHP : modèle de repository")
    bmap("<leader>ps", "i#[Service]<cr>class Service<cr>{<cr><cr>}<esc>2k$FSa", "PHP : modèle de service")
  end,
})
