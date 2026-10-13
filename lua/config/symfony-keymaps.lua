-- Raccourcis Symfony (buffer-local — chargés via FileType php,xml,yaml,twig
-- dans autocmds.lua). Les fichiers de config XML/YAML font partie du périmètre :
-- c'est là qu'on consulte l'index du conteneur DI.
--
-- Majuscule `<S>` pour éviter les conflits avec les defaults LazyVim
-- (`<leader>sr`, `<leader>ss`).
--
-- Module exposé comme fonction : `require` met le module en cache, donc un
-- `require("config.symfony-keymaps")` seul ne poserait les maps que sur le
-- premier buffer rencontré.

local function symfony_client()
  local clients = vim.lsp.get_clients({ bufnr = 0, name = "symfony_lsp" })
  return clients[1]
end

local function execute(command, arguments, on_result)
  local client = symfony_client()
  if not client then
    vim.notify("Symfony Language Tools n'est pas attaché à ce buffer.", vim.log.levels.WARN)
    return
  end
  client:request("workspace/executeCommand", {
    command = command,
    arguments = arguments or {},
  }, function(err, result)
    if err then
      vim.notify(("Symfony: %s a échoué — %s"):format(command, err.message or vim.inspect(err)), vim.log.levels.ERROR)
      return
    end
    if on_result then
      on_result(result)
    end
  end, 0)
end

-- `symfony.indexStatus` renvoie une entrée par racine d'appli détectée : un dépôt
-- peut en contenir plusieurs (ex. une appli principale et un sous-projet).
local function format_status(roots)
  if type(roots) ~= "table" or #roots == 0 then
    return "Symfony: aucune racine indexée."
  end
  local lines = {}
  for _, entry in ipairs(roots) do
    table.insert(
      lines,
      ("%s\n  env=%s  trusted=%s\n  source=%s  runtime=%s"):format(
        entry.root or "?",
        tostring(entry.environment),
        tostring(entry.trusted),
        tostring((entry.source or {}).state),
        tostring((entry.runtime or {}).state)
      )
    )
  end
  return table.concat(lines, "\n")
end

-- `gd` dans un fichier de config ou un template Symfony.
--
-- En XML, symfony-lsp n'expose aucune feature au curseur (le XML est indexé
-- comme cible de navigation seulement), et lemminx ne sait sauter que vers la
-- balise appariée : on résout donc le FQCN en PSR-4 d'abord.
--
-- En YAML et Twig, un nom de template (`'@Ns/….html.twig'`) est résolu sur le
-- disque d'abord : c'est déterministe, et twiggy a besoin de `debug:twig` pour
-- le faire. symfony-lsp gère ensuite les `@service`, `%param%` et routes ; le
-- PSR-4 sert de filet, et le `gd` standard laisse la main à twiggy (blocks,
-- macros, templates des bundles vendor).
local function goto_definition()
  local jump = require("config.symfony-goto")

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
    local response = client:request_sync(
      "textDocument/definition",
      vim.lsp.util.make_position_params(0, client.offset_encoding),
      1500,
      0
    )
    local result = response and response.result
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

-- `gd` passe par le registre de Snacks, pas par `vim.keymap.set` : LazyVim y
-- enregistre son propre `gd` avec un filtre LSP, et Snacks le repose (débounce
-- 100 ms) à chaque LspAttach. Une map posée à la main serait systématiquement
-- écrasée. Dans le registre, c'est l'enregistrement le plus récent qui gagne.
local registered = false

local function register_goto_definition()
  if registered then
    return
  end
  local ok, snacks = pcall(require, "snacks")
  if not ok then
    return
  end
  registered = true
  snacks.keymap.set("n", "gd", goto_definition, {
    -- Filtre vide = n'importe quel client LSP attaché ; `enabled` restreint aux
    -- fichiers de config et templates d'un projet Symfony.
    lsp = {},
    enabled = function(buf)
      return require("config.symfony-goto").is_symfony_config_buf(buf)
    end,
    desc = "Symfony: Aller à la classe / au template / à la définition",
  })
end

return function()
  local map = vim.keymap.set
  local buf = { buffer = 0 }

  local function opts(desc)
    return vim.tbl_extend("force", buf, { desc = desc })
  end

  register_goto_definition()

  -- Index du serveur Symfony (le lien config XML/YAML → classe PHP en dépend :
  -- sans index runtime, goto-definition ne renvoie rien depuis un services.xml).
  map("n", "<leader>Si", function()
    execute("symfony.indexStatus", {}, function(result)
      vim.notify(format_status(result), vim.log.levels.INFO, { title = "Symfony index" })
    end)
  end, opts("Symfony: Statut de l'index"))

  map("n", "<leader>SR", function()
    execute("symfony.refreshIndex", {}, function()
      vim.notify("Index Symfony rafraîchi.", vim.log.levels.INFO, { title = "Symfony index" })
    end)
  end, opts("Symfony: Rafraîchir l'index"))

  map("n", "<leader>SE", function()
    vim.ui.input({ prompt = "Environnement Symfony : ", default = "dev" }, function(env)
      if not env or env == "" then
        return
      end
      execute("symfony.switchEnvironment", { env }, function()
        vim.notify("Environnement Symfony : " .. env, vim.log.levels.INFO, { title = "Symfony index" })
      end)
    end)
  end, opts("Symfony: Changer d'environnement"))

  -- Symfony Console (déplacé depuis php-keymaps.lua pour être disponible aussi
  -- dans les fichiers de config).
  map("n", "<leader>Sc", "<cmd>!php bin/console ", opts("Symfony: Console command"))
  map("n", "<leader>Sm", "<cmd>!php bin/console make:", opts("Symfony: Make command"))
  map("n", "<leader>Sd", "<cmd>!php bin/console doctrine:", opts("Symfony: Doctrine command"))
  map("n", "<leader>Sr", "<cmd>!php bin/console debug:router<cr>", opts("Symfony: Debug routes"))
  map("n", "<leader>Ss", "<cmd>!php bin/console debug:container<cr>", opts("Symfony: Debug services"))
  map("n", "<leader>Se", "<cmd>!php bin/console debug:config<cr>", opts("Symfony: Debug config"))
end
