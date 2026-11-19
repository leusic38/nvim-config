-- neovimanu : config Neovim 0.12 sans LazyVim (NVIM_APPNAME=neovimanu).
--
-- Ce fichier ne fait que fixer l'ordre de chargement des modules lua/manu/*.lua.
-- Ordre prévu : options → autocmds → keymaps → pack_hooks (avant tout vim.pack.add)
-- → ui → treesitter → lsp → completion → format → lint → picker → files
-- → terminal → git → editing → ai → lang/* → dashboard (page d'accueil, au VimEnter).
-- Chaque module ajoute lui-même ses plugins (vim.pack.add) puis les configure.

require("manu.options")
require("manu.autocmds")
require("manu.keymaps")
require("manu.pack_hooks") -- avant tout vim.pack.add
require("manu.mason")
require("manu.ui")
require("manu.treesitter")
require("manu.lsp")
require("manu.completion")
require("manu.format")
require("manu.lint")
require("manu.picker")
require("manu.files")
require("manu.terminal")
require("manu.git")
require("manu.editing")
require("manu.ai")
require("manu.debug") -- nvim-dap (adaptateurs ajoutés par les langages)
require("manu.test") -- neotest (adaptateurs ajoutés par les langages)
require("manu.project") -- racine, conteneur, :Projet (utilisé par les langages)
require("manu.lang.lua")
require("manu.lang.markdown")
require("manu.lang.data")
require("manu.lang.php")
require("manu.lang.symfony")
require("manu.dashboard")
