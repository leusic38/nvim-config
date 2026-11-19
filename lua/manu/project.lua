-- Projet du buffer : racine, framework, conteneur Docker, outils du projet.
--
-- Règle : quand le projet déclare un conteneur (.nvim/docker.lua), ses outils (formateur,
-- analyseur, tests, console) tournent DANS le conteneur, jamais sur l'hôte — même s'il est
-- arrêté : on prévient alors comment le démarrer, on ne retombe pas sur l'hôte.
--
-- .nvim/docker.lua, à la racine du projet :
--   return {
--     service = "php", container_root = "/var/app/lama",         -- outils PHP
--     node = { service = "node", container_root = "/app" },       -- facultatif : outils JS
--   }
-- Sans entrée `node`, les outils JS vont dans le conteneur PHP s'il a Node (directement ou
-- via nvm, cas de lama : l'image installe Node avec nvm, hors du PATH d'un `sh -c`).
-- `node = false` force les outils JS sur l'hôte.
--
-- :Projet affiche ce qui a été détecté pour le buffer courant et l'outil retenu par rôle.

local M = {}

-- ─── Racine et framework ───────────────────────────────────────────────────

local function buf_path(bufnr)
  local name = vim.api.nvim_buf_get_name(bufnr or 0)
  if name == "" or name:match("^%a[%w+.-]*://") then
    return assert(vim.uv.cwd())
  end
  return name
end

--- Dossier du premier marqueur trouvé en remontant depuis le buffer.
---@param bufnr? integer
---@param markers? string[] défaut { "composer.json" }
---@return string|nil
function M.root(bufnr, markers)
  return vim.fs.root(buf_path(bufnr), markers or { "composer.json" })
end

---@param bufnr? integer
---@return "symfony"|"laravel"|nil
function M.framework(bufnr)
  local root = M.root(bufnr)
  if not root then
    return nil
  end
  if vim.uv.fs_stat(root .. "/bin/console") or vim.uv.fs_stat(root .. "/config/bundles.php") then
    return "symfony"
  end
  if vim.uv.fs_stat(root .. "/artisan") then
    return "laravel"
  end
  return nil
end

-- ─── Conteneur ─────────────────────────────────────────────────────────────

--- Conteneur déclaré pour un runtime, ou nil.
local function read_config(root)
  local path = root .. "/.nvim/docker.lua"
  if not vim.uv.fs_stat(path) then
    return nil
  end
  local ok, cfg = pcall(dofile, path)
  return ok and type(cfg) == "table" and cfg or nil
end

local function valid(cfg)
  if type(cfg) == "table" and type(cfg.service) == "string" and type(cfg.container_root) == "string" then
    return { service = cfg.service, container_root = cfg.container_root, setup = cfg.setup }
  end
end

local node_probe = {} -- racine → { setup = string|nil } | false

--- Node est-il dans le conteneur PHP ? Directement, ou via nvm (setup = ligne à exécuter
--- avant l'outil). Sondé une fois par session, quand le conteneur tourne ; arrêté, on le
--- suppose présent (règle : le conteneur plutôt que l'hôte).
function M._probe_node(root, service)
  if node_probe[root] ~= nil then
    return node_probe[root]
  end
  if not M.container_running(root, service) then
    return { setup = nil, unknown = true }
  end
  local script = 'command -v node >/dev/null && echo direct && exit; '
    .. '[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh" >/dev/null && command -v node >/dev/null && echo nvm'
  local ok, res = pcall(function()
    return vim.system({ "docker", "compose", "exec", "-T", service, "bash", "-c", script }, { cwd = root, text = true })
      :wait(10000)
  end)
  local out = ok and vim.trim(res.stdout or "") or ""
  if out == "direct" then
    node_probe[root] = { setup = nil }
  elseif out == "nvm" then
    node_probe[root] = { setup = '. "$NVM_DIR/nvm.sh" >/dev/null' }
  else
    node_probe[root] = false
  end
  return node_probe[root]
end

--- Conteneur d'un runtime, ou nil (outils sur l'hôte).
---@param root string|nil
---@param runtime? "php"|"node"
---@return { service: string, container_root: string, setup?: string }|nil
function M.docker(root, runtime)
  if not root then
    return nil
  end
  local cfg = read_config(root)
  if not cfg then
    return nil
  end
  local php = valid(cfg)
  if (runtime or "php") == "php" then
    return php
  end
  if cfg.node == false then
    return nil
  end
  if cfg.node ~= nil then
    return valid(cfg.node)
  end
  if not php then
    return nil
  end
  local probe = M._probe_node(root, php.service)
  if not probe then
    return nil
  end
  php.setup = probe.setup
  return php
end

function M.to_container(path, root, docker)
  if path:sub(1, #root) ~= root then
    return path
  end
  return docker.container_root .. path:sub(#root + 1)
end

function M.to_host(path, root, docker)
  local c = docker.container_root
  if path:sub(1, #c) ~= c then
    return path
  end
  return root .. path:sub(#c + 1)
end

local running_cache = {}

--- Le service tourne-t-il ? (docker compose ps, mis en cache 30 s)
---@param root string
---@param service string
function M.container_running(root, service)
  local key = root .. "\0" .. service
  local cached = running_cache[key]
  if cached and vim.uv.now() - cached.at < 30000 then
    return cached.value
  end
  local ok, res = pcall(function()
    return vim.system({ "docker", "compose", "ps", "--status", "running", "-q", service }, { cwd = root, text = true })
      :wait(3000)
  end)
  local value = ok and res.code == 0 and vim.trim(res.stdout or "") ~= ""
  running_cache[key] = { value = value, at = vim.uv.now() }
  return value
end

local warned = {}

--- Commande à lancer depuis `root` : dans le conteneur du runtime s'il est déclaré.
--- Renvoie nil + message si le conteneur est déclaré mais arrêté (pas de repli hôte) ;
--- le message est aussi notifié, une fois par session et par service.
---@param root string
---@param argv string[]
---@param runtime? "php"|"node"
---@return string[]|nil, string?
function M.cmd(root, argv, runtime)
  local docker = M.docker(root, runtime)
  if not docker then
    return argv
  end
  if not M.container_running(root, docker.service) then
    local msg = ("Conteneur %s arrêté : docker compose up -d %s"):format(docker.service, docker.service)
    local key = root .. "\0" .. docker.service
    if not warned[key] then
      warned[key] = true
      vim.schedule(function()
        vim.notify(msg, vim.log.levels.WARN)
      end)
    end
    return nil, msg
  end
  -- -w : l'outil part de la racine du projet dans le conteneur (il y trouve sa config).
  local base = { "docker", "compose", "exec", "-T", "-w", docker.container_root, docker.service }
  if docker.setup then
    -- Ex. nvm : charger l'environnement, puis lancer l'outil avec ses arguments intacts.
    vim.list_extend(base, { "bash", "-c", docker.setup .. ' && exec "$@"', "manu" })
  end
  return vim.list_extend(base, argv)
end

-- ─── Outils du projet ──────────────────────────────────────────────────────

local function read_json(path)
  local ok, lines = pcall(vim.fn.readfile, path)
  if not ok then
    return nil
  end
  local ok2, data = pcall(vim.json.decode, table.concat(lines, "\n"))
  return ok2 and type(data) == "table" and data or nil
end

--- Dossier des binaires Composer du projet (relatif à la racine).
function M.bin_dir(root)
  local composer = read_json(root .. "/composer.json") or {}
  local dir = vim.tbl_get(composer, "config", "bin-dir")
  return (type(dir) == "string" and dir or "vendor/bin"):gsub("/$", "")
end

--- Binaire Composer du projet, relatif à la racine (« bin/phpstan »), ou nil s'il n'existe pas.
---@param root string
---@param name string
function M.bin(root, name)
  local rel = M.bin_dir(root) .. "/" .. name
  if vim.uv.fs_stat(root .. "/" .. rel) then
    return rel
  end
  return nil
end

--- Binaire node_modules/.bin du projet, relatif à la racine, ou nil.
function M.node_bin(root, name)
  local rel = "node_modules/.bin/" .. name
  if vim.uv.fs_stat(root .. "/" .. rel) then
    return rel
  end
  return nil
end

-- ─── :Projet ───────────────────────────────────────────────────────────────

---@type table<string, fun(bufnr: integer): string|nil>
local reporters = {}

--- Un fichier de langage décrit l'outil qu'il retient pour un rôle (« php : formateur »…).
---@param role string
---@param fn fun(bufnr: integer): string|nil texte, ou nil si sans objet pour ce buffer
function M.report(role, fn)
  reporters[role] = fn
end

function M.describe(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  local lines = {}
  local root = M.root(bufnr, { "composer.json", "package.json", ".git" })
  table.insert(lines, "Racine       : " .. (root and vim.fn.fnamemodify(root, ":~") or "(aucune)"))
  table.insert(lines, "Framework    : " .. (M.framework(bufnr) or "-"))
  for _, runtime in ipairs({ "php", "node" }) do
    local d = M.docker(root, runtime)
    local state = "hôte"
    if d then
      state = ("%s → %s (%s)%s"):format(
        d.service,
        d.container_root,
        M.container_running(root, d.service) and "en marche" or "arrêté",
        d.setup and ", via nvm" or ""
      )
    end
    table.insert(lines, ("%-13s: %s"):format("Outils " .. runtime, state))
  end
  local roles = vim.tbl_keys(reporters)
  table.sort(roles)
  for _, role in ipairs(roles) do
    local ok, text = pcall(reporters[role], bufnr)
    if ok and text then
      table.insert(lines, ("%-13s: %s"):format(role, text))
    end
  end
  return lines
end

vim.api.nvim_create_user_command("Projet", function()
  vim.notify(table.concat(M.describe(), "\n"), vim.log.levels.INFO, { title = "Projet" })
end, { desc = "Ce que la config a détecté pour le projet du buffer courant" })

return M
