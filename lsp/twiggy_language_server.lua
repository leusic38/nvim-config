---@brief
---
--- https://github.com/moetelo/twiggy
---
--- Complète la config nvim-lspconfig (cmd, filetypes, root_markers) : les deux
--- fichiers `lsp/twiggy_language_server.lua` du runtimepath sont fusionnés.
---
--- twiggy lit l'environnement Twig de l'appli via `bin/console debug:twig`
--- (fonctions, filtres, globals, namespaces de templates) et `debug:router`.
--- Sans ça : ni complétion des fonctions/filtres, ni résolution des
--- `@Namespace/…` vers les fichiers.
---
--- Pour un projet dockerisé, `twiggy.phpExecutable` pointe vers un shim par
--- projet, généré dans le cache à partir du `.nvim/docker.lua` (même convention
--- que lsp/symfony_lsp.lua et le PHP CS Fixer de lua/plugins/php.lua). Le shim
--- délègue à bin/twiggy-php, qui lance `bin/console` dans le conteneur et
--- garde le PHP de l'hôte pour les utilitaires de twiggy.

local config_dir = vim.fn.stdpath("config")

-- Lit `.nvim/docker.lua` à la racine du workspace twiggy.
-- Retourne { service = "php", container_root = "/var/app/lama" } ou nil.
local function read_docker_config(root)
  if not root then
    return nil
  end
  local path = root .. "/.nvim/docker.lua"
  if not vim.uv.fs_stat(path) then
    return nil
  end
  local ok, cfg = pcall(dofile, path)
  if ok and type(cfg) == "table" and cfg.service and cfg.container_root then
    return cfg
  end
  return nil
end

-- Un shim par racine : `phpExecutable` est un chemin seul, sans arguments.
-- Réécrit à chaque démarrage pour suivre les changements de docker.lua.
local function write_php_shim(root, docker)
  local dir = vim.fn.stdpath("cache") .. "/twiggy"
  vim.fn.mkdir(dir, "p")
  local path = ("%s/php-%s"):format(dir, vim.fn.sha256(root):sub(1, 12))
  local lines = {
    "#!/bin/sh",
    ("exec %s %s %s %s \"$@\""):format(
      vim.fn.shellescape(config_dir .. "/bin/twiggy-php"),
      vim.fn.shellescape(root),
      vim.fn.shellescape(docker.service),
      vim.fn.shellescape(docker.container_root)
    ),
  }
  if vim.fn.writefile(lines, path) ~= 0 then
    return nil
  end
  vim.uv.fs_chmod(path, tonumber("755", 8))
  return path
end

---@type vim.lsp.Config
return {
  root_markers = { "composer.json" },
  settings = {
    twiggy = {
      framework = "symfony",
      phpExecutable = "php",
      symfonyConsolePath = "./bin/console",
      -- twiggy ne lance twig-cs-fixer que via `vendor/bin/twig-cs-fixer` et
      -- le `phpExecutable` ; nvim-lint s'en charge déjà (lua/plugins/twig.lua),
      -- avec le binaire Mason en repli. Évite les diagnostics en double.
      diagnostics = { twigCsFixer = false },
    },
  },
  -- `before_init` et pas `on_init` : Neovim pousse `workspace/didChangeConfiguration`
  -- entre la réponse à `initialize` et `on_init`, et twiggy charge
  -- l'environnement Twig dès cette première config. Trop tard, il démarrerait
  -- avec le PHP de l'hôte (boot de l'appli hors conteneur, OOM sur lama).
  --
  -- Modification en place : `client.settings` est la même table que
  -- `config.settings`, la réassigner n'aurait aucun effet.
  before_init = function(_, config)
    local docker = read_docker_config(config.root_dir)
    if not docker then
      return
    end
    local shim = write_php_shim(config.root_dir, docker)
    if not shim then
      vim.notify("twiggy: impossible d'écrire le shim PHP Docker.", vim.log.levels.WARN)
      return
    end
    config.settings.twiggy.phpExecutable = shim
  end,
}
