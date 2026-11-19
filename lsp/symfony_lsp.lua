---@brief
---
--- https://github.com/symfony/language-tools
---
--- Symfony Language Tools : complétion, navigation, références, diagnostics,
--- code actions, rename et code lenses spécifiques à Symfony, en complément
--- d'un LSP PHP généraliste (Intelephense reste le serveur PHP principal).
---
--- Binaire installé via Mason (`symfony-lsp`), voir lua/manu/lang/symfony.lua.
---
--- Différences avec la config upstream :
---   * `root_markers` remplacé par un `root_dir` qui exige une vraie appli
---     Symfony (`bin/console` ou `config/bundles.php` à la racine du
---     `composer.json`). Upstream accepte `.git`, ce qui attache le serveur
---     dans n'importe quel dépôt git (dont cette config Neovim).
---   * `json`/`javascript`/`typescript` retirés des `filetypes` pour ne pas
---     doubler la stack JS/TS (cf. lua/plugins/javascript.lua).
---
--- L'indexing runtime exécute `bin/console` : le serveur demande confirmation
--- (workspace trust) au premier attach. Pour un projet dockerisé, `phpCommand` et
--- `containerProjectRoot` sont dérivés du `.nvim/docker.lua` du projet (même
--- convention que php-cs-fixer, cf. lua/manu/project.lua) et envoyés
--- au serveur via `workspace/didChangeConfiguration`.
---
--- Sans index runtime, `textDocument/definition` ne renvoie rien depuis les
--- fichiers de config XML/YAML : le lien service → classe PHP passe par le dump
--- du conteneur DI. Le handler `window/showMessageRequest` ci-dessous répond donc
--- automatiquement « trust » pour les projets qui ont un dossier `.nvim/`
--- (`docker.lua`, `dap.lua` : marqueur d'un projet configuré à la main, donc
--- opt-in explicite). Les autres gardent le prompt standard.

-- Conteneur du projet : manu.project (lecture de `.nvim/docker.lua`), comme les autres outils.
local function read_docker_config(root)
  return require("manu.project").docker(root)
end

-- Le message de trust cite la racine concernée entre guillemets. Un dépôt peut
-- contenir plusieurs applis Symfony (ex. `lama` + `lama/mcp`), chacune promptée
-- séparément.
local function prompted_root(message)
  return message and message:match('"([^"]+)"') or nil
end

-- Opt-in explicite : un dossier `.nvim/` à la racine promptée, ou à la racine du
-- workspace qui la contient (l'opt-in vaut pour les sous-applis du dépôt).
-- Un dépôt fraîchement cloné n'en a pas : il garde le prompt.
local function is_trusted_root(root, client)
  local candidates = {}
  if root then
    table.insert(candidates, root)
  end
  local workspace = client and client.root_dir
  if workspace and workspace ~= root then
    table.insert(candidates, workspace)
  end
  for _, dir in ipairs(candidates) do
    local stat = vim.uv.fs_stat(dir .. "/.nvim")
    if stat and stat.type == "directory" then
      return true
    end
  end
  return false
end

local function find_trust_action(actions)
  for _, action in ipairs(actions or {}) do
    if type(action.title) == "string" and action.title:lower():find("trust", 1, true) then
      return action
    end
  end
  return nil
end

---@type vim.lsp.Config
return {
  cmd = { "symfony-lsp" },
  filetypes = { "php", "twig", "yaml", "xml", "env" },
  root_dir = function(bufnr, on_dir)
    local fname = vim.api.nvim_buf_get_name(bufnr)
    local root = vim.fs.root(fname ~= "" and fname or assert(vim.uv.cwd()), { "composer.json" })
    if not root then
      return
    end
    -- Ne s'active que sur une appli Symfony, pas sur n'importe quel projet PHP.
    if vim.uv.fs_stat(root .. "/bin/console") or vim.uv.fs_stat(root .. "/config/bundles.php") then
      on_dir(root)
    end
  end,
  workspace_required = true,
  handlers = {
    -- Auto-répond « Trust and enable runtime indexing » sur les projets opt-in,
    -- sinon délègue au prompt standard de Neovim.
    ["window/showMessageRequest"] = function(err, result, ctx)
      local client = vim.lsp.get_client_by_id(ctx.client_id)
      local action = find_trust_action(result and result.actions)
      if action and is_trusted_root(prompted_root(result.message), client) then
        return action
      end
      return vim.lsp.handlers["window/showMessageRequest"](err, result, ctx)
    end,
  },
  capabilities = {
    workspace = {
      didChangeWatchedFiles = {
        dynamicRegistration = true,
      },
    },
  },
  init_options = {},
  settings = {
    symfonyLsp = {},
  },
  -- Sans `phpCommand`, l'indexation runtime lance le PHP de l'hôte, dont la
  -- version ne correspond pas forcément à celle de l'appli. `client.settings` est
  -- poussé au serveur juste après `on_init` par Neovim.
  on_init = function(client)
    local docker = read_docker_config(client.root_dir)
    if not docker then
      return
    end
    client.settings = vim.tbl_deep_extend("force", client.settings or {}, {
      symfonyLsp = {
        phpCommand = { "docker", "compose", "exec", "-T", docker.service, "php" },
        containerProjectRoot = docker.container_root,
      },
    })
  end,
  commands = {
    ["editor.action.showReferences"] = function(command, ctx)
      local client = assert(vim.lsp.get_client_by_id(ctx.client_id))
      local arguments = command.arguments or {}
      local uri = arguments[1]
      local position = arguments[2]
      local references = arguments[3]
      if type(uri) ~= "string" or type(position) ~= "table" or type(references) ~= "table" then
        vim.notify("Symfony Language Tools returned an invalid reference command.", vim.log.levels.ERROR)
        return
      end

      local items = vim.lsp.util.locations_to_items(references, client.offset_encoding)
      vim.fn.setqflist({}, " ", {
        title = command.title,
        items = items,
        context = {
          command = command,
          bufnr = ctx.bufnr,
        },
      })
      vim.lsp.util.show_document({
        uri = uri,
        range = {
          start = position,
          ["end"] = position,
        },
      }, client.offset_encoding)
      vim.cmd("botright copen")
    end,
  },
}
