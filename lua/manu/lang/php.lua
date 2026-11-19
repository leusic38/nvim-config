-- Langage PHP (modèle de lang/lua.lua). Symfony (twig, xml, yaml de config, navigation,
-- console) : lang/symfony.lua.
--
-- Pas de php.vim (StanAngeloff) : Treesitter remplace la coloration Vim, et ses options ne
-- servaient qu'à couper les injections HTML/SQL de cette coloration.

local project = require("manu.project")

-- 2. Outils : Intelephense (serveur). Il reste sur l'hôte même si le projet est dockerisé :
--    il lit les fichiers (vendor/ compris), il n'exécute pas le code du projet.
require("manu.mason").ensure({ "intelephense" })

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

-- 5–6. Formateur et analyseur : php-cs-fixer, PHPStan (plus bas, Task 3 du plan 2).

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
