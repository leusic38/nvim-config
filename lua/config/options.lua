-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

vim.g.lazyvim_php_lsp = "intelephense"

-- Spell checking configuration
vim.opt.spelllang = { "en", "fr" } -- Support anglais et français
vim.opt.spell = false -- Désactivé par défaut, activer avec <leader>us

-- ─── YAML : toujours 2 espaces ────────────────────────────────────────────────
-- L'ftplugin yaml du runtime pose déjà sw/sts=2, mais le support .editorconfig
-- intégré à Neovim s'applique *après* FileType et écrase la valeur dès qu'un
-- projet déclare indent_size = 4. Un autocmd FileType perdrait donc la course :
-- on enveloppe directement les handlers d'editorconfig pour neutraliser
-- l'indentation sur les buffers YAML uniquement (le reste du .editorconfig —
-- charset, fins de ligne, trim, max_line_length — continue de s'appliquer).
local editorconfig = require("editorconfig")

local function is_yaml(bufnr)
  if vim.bo[bufnr].filetype:match("^yaml") then
    return true
  end
  return vim.api.nvim_buf_get_name(bufnr):match("%.ya?ml$") ~= nil
end

local function force_on_yaml(prop, forced)
  local original = editorconfig.properties[prop]
  editorconfig.properties[prop] = function(bufnr, val, opts)
    return original(bufnr, is_yaml(bufnr) and forced or val, opts)
  end
end

force_on_yaml("indent_size", "2")
force_on_yaml("tab_width", "2")
force_on_yaml("indent_style", "space")
