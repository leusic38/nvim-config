-- Sauts « FQCN sous le curseur → fichier de classe PHP » et « nom de template
-- Twig sous le curseur → fichier » pour les fichiers de config Symfony et les
-- templates Twig.
--
-- Pourquoi : symfony-lsp indexe les définitions de services XML comme *cible* de
-- navigation, mais n'expose aucune feature au curseur dans un fichier XML
-- (cf. docs/features/dependency-injection.rst upstream). Depuis un
-- `Resources/config/services.xml`, `gd` ne renvoie donc rien. La résolution
-- PSR-4 du composer.json comble ce trou sans serveur, et sert aussi de filet en
-- YAML quand symfony-lsp ne reconnaît pas la position.
--
-- Côté templates, twiggy résout les `@Namespace/…` à partir de
-- `bin/console debug:twig` : rien ne marche tant que l'appli (ou le conteneur)
-- n'a pas répondu. La résolution statique ci-dessous couvre les bundles du
-- projet sans dépendre du runtime ; les bundles vendor restent à twiggy.

local M = {}

-- Cache par racine de projet : le composer.json ne bouge quasiment jamais, et on
-- passe ici à chaque `gd`.
local cache = {}

local function project_root(bufnr)
  local fname = vim.api.nvim_buf_get_name(bufnr)
  return vim.fs.root(fname ~= "" and fname or assert(vim.uv.cwd()), { "composer.json" })
end

-- Les préfixes PSR-4 sont testés du plus long au plus court : `Theia\Tests\` doit
-- l'emporter sur `Theia\`.
local function load_psr4(root)
  if cache[root] then
    return cache[root]
  end

  local ok, content = pcall(vim.fn.readfile, root .. "/composer.json")
  if not ok then
    cache[root] = {}
    return cache[root]
  end

  local decoded_ok, composer = pcall(vim.json.decode, table.concat(content, "\n"))
  if not decoded_ok or type(composer) ~= "table" then
    cache[root] = {}
    return cache[root]
  end

  local prefixes = {}
  for _, section in ipairs({ "autoload", "autoload-dev" }) do
    local psr4 = (composer[section] or {})["psr-4"] or {}
    for prefix, dirs in pairs(psr4) do
      -- Une valeur PSR-4 est un chemin ou une liste de chemins.
      table.insert(prefixes, { prefix = prefix, dirs = type(dirs) == "table" and dirs or { dirs } })
    end
  end
  table.sort(prefixes, function(a, b)
    return #a.prefix > #b.prefix
  end)

  cache[root] = prefixes
  return prefixes
end

-- Buffer de config ou template Symfony : le fallback `gd` ne doit s'activer que
-- là (pas sur un docker-compose.yml, un playbook Ansible ou un pom.xml).
local symfony_filetypes = { xml = true, yaml = true, twig = true }

function M.is_symfony_config_buf(bufnr)
  bufnr = bufnr or 0
  if not symfony_filetypes[vim.bo[bufnr].filetype] then
    return false
  end
  local root = project_root(bufnr)
  if not root then
    return false
  end
  return vim.uv.fs_stat(root .. "/bin/console") ~= nil or vim.uv.fs_stat(root .. "/config/bundles.php") ~= nil
end

-- Un FQCN peut apparaître dans `id="Theia\..."`, `'@Theia\...'` ou `Theia\...:`.
-- On prend la plus longue suite de caractères de classe autour du curseur.
function M.fqcn_under_cursor()
  local line = vim.api.nvim_get_current_line()
  local col = vim.api.nvim_win_get_cursor(0)[2] + 1

  local start_col = col
  while start_col > 1 and line:sub(start_col - 1, start_col - 1):match("[%w_\\]") do
    start_col = start_col - 1
  end
  local end_col = col
  while end_col <= #line and line:sub(end_col, end_col):match("[%w_\\]") do
    end_col = end_col + 1
  end

  local token = line:sub(start_col, end_col - 1)
  -- Sans backslash ce n'est pas un FQCN mais un id de service (`security.foo`),
  -- un nom de tag ou un mot quelconque : ce n'est pas notre affaire.
  if not token:find("\\") then
    return nil
  end
  return (token:gsub("^\\", ""))
end

function M.resolve(fqcn, root)
  for _, entry in ipairs(load_psr4(root)) do
    if fqcn:sub(1, #entry.prefix) == entry.prefix then
      local relative = fqcn:sub(#entry.prefix + 1):gsub("\\", "/")
      for _, dir in ipairs(entry.dirs) do
        local path = root .. "/" .. (dir:gsub("/$", "")) .. "/" .. relative .. ".php"
        if vim.uv.fs_stat(path) then
          return path
        end
      end
    end
  end
  return nil
end

-- Retourne true si le saut a eu lieu, false sinon (l'appelant enchaîne alors sur
-- le comportement `gd` par défaut).
function M.goto_class()
  local fqcn = M.fqcn_under_cursor()
  if not fqcn then
    return false
  end

  local root = project_root(0)
  if not root then
    return false
  end

  local path = M.resolve(fqcn, root)
  if not path then
    return false
  end

  vim.cmd("edit " .. vim.fn.fnameescape(path))

  local short = fqcn:match("([^\\]+)$")
  if short then
    vim.fn.search([[\v<(class|interface|trait|enum)>\s+]] .. short .. [[>]], "cw")
  end
  return true
end

-- Nom de template sous le curseur : le contenu de la chaîne qui l'entoure, s'il
-- se termine par `.twig` (`{% include '…' %}`, `form_themes:` en YAML…).
function M.template_under_cursor()
  local line = vim.api.nvim_get_current_line()
  local col = vim.api.nvim_win_get_cursor(0)[2] + 1

  local init = 1
  while true do
    local s, e, name = line:find([=[["']([^"']+%.twig)["']]=], init)
    if not s then
      return nil
    end
    if col >= s and col <= e then
      return name
    end
    init = e + 1
  end
end

-- Dossier du bundle `<Namespace>Bundle` du projet, via sa classe
-- `<Namespace>Bundle.php` sous `src/`. Mis en cache, y compris les échecs.
local bundle_dirs = {}

local function bundle_dir(root, namespace)
  local key = root .. "\0" .. namespace
  if bundle_dirs[key] == nil then
    local found = vim.fs.find(namespace .. "Bundle.php", { path = root .. "/src", type = "file", limit = 1 })[1]
    bundle_dirs[key] = found and vim.fs.dirname(found) or false
  end
  return bundle_dirs[key] or nil
end

-- `ide-twig.json` (format PhpStorm, souvent versionné) : namespace → dossier.
local function ide_twig_paths(root, namespace)
  local ok, content = pcall(vim.fn.readfile, root .. "/ide-twig.json")
  if not ok then
    return {}
  end
  local decoded_ok, ide = pcall(vim.json.decode, table.concat(content, "\n"))
  if not decoded_ok or type(ide) ~= "table" then
    return {}
  end
  local paths = {}
  for _, entry in ipairs(ide.namespaces or {}) do
    if (entry.namespace or "") == namespace and entry.path then
      table.insert(paths, root .. "/" .. entry.path)
    end
  end
  return paths
end

-- Candidats dans l'ordre de résolution de Symfony : surcharge
-- `templates/bundles/<Ns>Bundle` d'abord, dossier du bundle ensuite.
function M.resolve_template(name, root)
  -- `@!Ns` désigne le template d'origine (sans surcharge) ; `//` est toléré
  -- par le loader et se rencontre dans les templates.
  name = name:gsub("/+", "/")
  local namespace, relative = name:match("^@!?([^/]+)/(.+)$")

  local dirs = {}
  if namespace then
    table.insert(dirs, root .. "/templates/bundles/" .. namespace .. "Bundle")
    vim.list_extend(dirs, ide_twig_paths(root, namespace))
    local bundle = bundle_dir(root, namespace)
    if bundle then
      table.insert(dirs, bundle .. "/Resources/views")
      table.insert(dirs, bundle .. "/templates")
    end
  else
    relative = name
    table.insert(dirs, root .. "/templates")
    vim.list_extend(dirs, ide_twig_paths(root, ""))
    table.insert(dirs, root .. "/app/Resources/views")
  end

  for _, dir in ipairs(dirs) do
    local path = dir .. "/" .. relative
    if vim.uv.fs_stat(path) then
      return path
    end
  end
  return nil
end

-- Même contrat que goto_class.
function M.goto_template()
  local name = M.template_under_cursor()
  if not name then
    return false
  end

  local root = project_root(0)
  if not root then
    return false
  end

  local path = M.resolve_template(name, root)
  if not path then
    return false
  end

  vim.cmd("edit " .. vim.fn.fnameescape(path))
  return true
end

return M
