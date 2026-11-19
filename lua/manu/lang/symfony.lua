-- Symfony : serveur symfony-lsp, navigation `gd` config → classe / template, console,
-- Composer, et les langages de la config Symfony :
--   Twig : twiggy-language-server (fonctions/filtres/globals de l'appli via bin/console
--          debug:twig, dans le conteneur : lsp/twiggy_language_server.lua + bin/twiggy-php),
--          Twig-CS-Fixer en lint partout, en formatage seulement avec config projet.
--   XML  : lemminx (validation XSD des services.xml, doctrine-mapping…, complétion, format).
--   YAML / JSON génériques : lang/data.lua.
--
-- `gd` : posé sur FileType, donc avant LspAttach ; lsp.lua ne pose pas le sien sur un
-- buffer qui en a déjà un (plus de registre de raccourcis comme avec Snacks).
-- Console et Composer : dans le conteneur du projet (manu.project), sortie dans un
-- terminal flottant (au lieu de `:!`, qui bloque l'éditeur et tourne sur l'hôte).

local project = require("manu.project")
local jump = require("manu.symfony_goto")

require("manu.mason").ensure({ "symfony-lsp", "twiggy-language-server", "twig-cs-fixer", "lemminx" })

vim.lsp.config("lemminx", {
  filetypes = { "xml", "xsd", "xsl", "xslt", "svg" },
  settings = {
    xml = {
      -- Les XSD Symfony sont référencés par URL (http://symfony.com/…) : sans téléchargement,
      -- pas de validation. lemminx les met en cache après le premier accès.
      downloadExternalResources = { enabled = true },
      -- Ne pas résoudre les entités externes d'un document (XXE).
      validation = { enabled = true, resolveExternalEntities = false },
      format = { enabled = true, splitAttributes = false, joinCDATALines = false, preserveEmptyContent = true },
      completion = { autoCloseTags = true },
    },
  },
})

vim.lsp.enable({ "symfony_lsp", "twiggy_language_server", "lemminx" })

-- Twig-CS-Fixer : binaire du projet dans le conteneur s'il l'a, sinon celui de Mason sur
-- l'hôte (outil autonome, que l'image du projet n'a pas forcément).
local TWIG_CS_CONFIGS = { ".twig-cs-fixer.php", ".twig-cs-fixer.dist.php" }
local function twig_cs_argv(bufnr, args)
  local root = project.root(bufnr) or vim.fs.dirname(vim.api.nvim_buf_get_name(bufnr))
  local argv = project.tool(root, "twig-cs-fixer", args, { host_if_missing = true })
  return argv, root
end

local lint = require("lint")
lint.linters.twig_cs_fixer_project = function()
  local bufnr = vim.api.nvim_get_current_buf()
  local base = require("lint.linters.twig-cs-fixer")
  local argv, root = twig_cs_argv(bufnr, function(path)
    return { "lint", "--report", "github", "--debug", path(vim.api.nvim_buf_get_name(bufnr)) }
  end)
  argv = argv or { "false" }
  return vim.tbl_extend("force", base, {
    cmd = argv[1],
    args = vim.list_slice(argv, 2),
    cwd = root,
    append_fname = false,
  })
end
lint.linters_by_ft.twig = { "twig_cs_fixer_project" }

require("conform").formatters.twig_cs_fixer_project = {
  condition = function(_, ctx)
    return require("manu.format").project_has(TWIG_CS_CONFIGS, ctx.buf)
      and twig_cs_argv(ctx.buf, function()
        return {}
      end) ~= nil
  end,
  command = function(_, ctx)
    return (twig_cs_argv(ctx.buf, function()
      return {}
    end) or { "false" })[1]
  end,
  args = function(_, ctx)
    local argv = twig_cs_argv(ctx.buf, function(path)
      return { "lint", "--fix", "--no-interaction", "--quiet", path(ctx.filename) }
    end)
    return vim.list_slice(argv or {}, 2)
  end,
  cwd = function(_, ctx)
    return project.root(ctx.buf)
  end,
  stdin = false,
}
require("conform").formatters_by_ft.twig = { "twig_cs_fixer_project" }

require("manu.treesitter").install({ "twig", "html", "xml" })

project.report("twig : lint", function(bufnr)
  if vim.bo[bufnr].filetype ~= "twig" then
    return nil
  end
  local argv = twig_cs_argv(bufnr, function(path)
    return { "lint", path(vim.api.nvim_buf_get_name(bufnr)) }
  end)
  return argv and table.concat(argv, " ") or "conteneur arrêté"
end)

-- ─── Commandes du serveur ──────────────────────────────────────────────────

local function symfony_client(bufnr)
  return vim.lsp.get_clients({ bufnr = bufnr or 0, name = "symfony_lsp" })[1]
end

local function execute(command, arguments, on_result)
  local client = symfony_client()
  if not client then
    vim.notify("Symfony Language Tools n'est pas attaché à ce buffer.", vim.log.levels.WARN)
    return
  end
  client:request("workspace/executeCommand", { command = command, arguments = arguments or {} }, function(err, result)
    if err then
      vim.notify(("Symfony : %s a échoué — %s"):format(command, err.message or vim.inspect(err)), vim.log.levels.ERROR)
      return
    end
    if on_result then
      on_result(result)
    end
  end, 0)
end

-- `symfony.indexStatus` renvoie une entrée par racine d'appli détectée.
local function format_status(roots)
  if type(roots) ~= "table" or #roots == 0 then
    return "Symfony : aucune racine indexée."
  end
  local lines = {}
  for _, e in ipairs(roots) do
    table.insert(lines, ("%s\n  env=%s  trusted=%s\n  source=%s  runtime=%s"):format(
      e.root or "?",
      tostring(e.environment),
      tostring(e.trusted),
      tostring((e.source or {}).state),
      tostring((e.runtime or {}).state)
    ))
  end
  return table.concat(lines, "\n")
end

-- ─── gd ────────────────────────────────────────────────────────────────────
-- XML : symfony-lsp n'expose rien au curseur, lemminx ne saute qu'à la balise appariée :
-- résolution PSR-4 d'abord. YAML / Twig / PHP : nom de template sur le disque d'abord, puis
-- symfony-lsp (@service, %param%, routes), puis PSR-4, puis le gd LSP standard.
local function goto_definition()
  if vim.bo.filetype == "xml" then
    if jump.goto_class() or jump.goto_template() then
      return
    end
    return vim.lsp.buf.definition()
  end
  if jump.goto_template() then
    return
  end
  local client = symfony_client()
  if client then
    local resp = client:request_sync(
      "textDocument/definition",
      vim.lsp.util.make_position_params(0, client.offset_encoding),
      1500,
      0
    )
    local result = resp and resp.result
    local location = result and (result.uri and result or result[1])
    if location then
      return vim.lsp.util.show_document(location, client.offset_encoding, { focus = true })
    end
  end
  if jump.goto_class() then
    return
  end
  return vim.lsp.buf.definition()
end

-- ─── Console et Composer (dans le conteneur) ───────────────────────────────

--- Lance argv à la racine du projet, dans le conteneur s'il y en a un.
local function run(bufnr, argv, title)
  local root = project.root(bufnr)
  if not root then
    return vim.notify("Pas de composer.json au-dessus de ce fichier.", vim.log.levels.WARN)
  end
  local cmd, err = project.cmd(root, argv)
  if not cmd then
    return vim.notify(err, vim.log.levels.WARN)
  end
  return require("manu.terminal").run(cmd, { cwd = root, title = title })
end

--- Demande la suite d'une commande, puis la lance.
local function ask(bufnr, prompt, prefix, argv_prefix, title)
  vim.ui.input({ prompt = prompt, default = prefix }, function(input)
    if input and vim.trim(input) ~= "" then
      run(bufnr, vim.list_extend(vim.deepcopy(argv_prefix), vim.split(vim.trim(input), "%s+")), title)
    end
  end)
end

local M = { _run = run }

vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("manu_symfony", { clear = true }),
  pattern = { "php", "xml", "yaml", "twig" },
  callback = function(ev)
    local buf = ev.buf
    local function bmap(lhs, rhs, desc)
      vim.keymap.set("n", lhs, rhs, { buffer = buf, desc = desc })
    end

    -- Composer : tout projet PHP qui a un composer.json.
    if vim.bo[buf].filetype == "php" and project.root(buf) then
      bmap("<leader>Cu", function()
        run(buf, { "composer", "update" }, "composer update")
      end, "Composer : update")
      bmap("<leader>Ci", function()
        run(buf, { "composer", "install" }, "composer install")
      end, "Composer : install")
      bmap("<leader>Cd", function()
        run(buf, { "composer", "dump-autoload" }, "composer dump-autoload")
      end, "Composer : dump-autoload")
      bmap("<leader>Cr", function()
        ask(buf, "composer require ", "", { "composer", "require" }, "composer require")
      end, "Composer : require")
    end

    if project.framework(buf) ~= "symfony" then
      return
    end

    -- gd : config et templates seulement (PHP : celui du LSP, Intelephense).
    if jump.is_symfony_config_buf(buf) then
      bmap("gd", goto_definition, "Symfony : aller à la classe / au template / à la définition")
    end

    bmap("<leader>Si", function()
      execute("symfony.indexStatus", {}, function(result)
        vim.notify(format_status(result), vim.log.levels.INFO, { title = "Index Symfony" })
      end)
    end, "Symfony : statut de l'index")
    bmap("<leader>SR", function()
      execute("symfony.refreshIndex", {}, function()
        vim.notify("Index Symfony rafraîchi.", vim.log.levels.INFO, { title = "Index Symfony" })
      end)
    end, "Symfony : rafraîchir l'index")
    bmap("<leader>SE", function()
      vim.ui.input({ prompt = "Environnement Symfony : ", default = "dev" }, function(env)
        if env and env ~= "" then
          execute("symfony.switchEnvironment", { env }, function()
            vim.notify("Environnement Symfony : " .. env, vim.log.levels.INFO, { title = "Index Symfony" })
          end)
        end
      end)
    end, "Symfony : changer d'environnement")

    local console = { "php", "bin/console" }
    bmap("<leader>Sc", function()
      ask(buf, "bin/console ", "", console, "bin/console")
    end, "Symfony : commande console")
    bmap("<leader>Sm", function()
      ask(buf, "bin/console ", "make:", console, "make")
    end, "Symfony : commande make:")
    bmap("<leader>Sd", function()
      ask(buf, "bin/console ", "doctrine:", console, "doctrine")
    end, "Symfony : commande doctrine:")
    bmap("<leader>Sr", function()
      run(buf, { "php", "bin/console", "debug:router" }, "debug:router")
    end, "Symfony : routes")
    bmap("<leader>Ss", function()
      run(buf, { "php", "bin/console", "debug:container" }, "debug:container")
    end, "Symfony : services")
    bmap("<leader>Se", function()
      run(buf, { "php", "bin/console", "debug:config" }, "debug:config")
    end, "Symfony : configuration")

  end,
})

return M
