-- neovimanu : config Neovim 0.12 sans LazyVim (NVIM_APPNAME=neovimanu).
--
-- Ce fichier ne fait que fixer l'ordre de chargement des modules lua/manu/*.lua.
-- Ordre prévu : options → autocmds → keymaps → pack_hooks (avant tout vim.pack.add)
-- → ui → treesitter → lsp → completion → format → lint → picker → files
-- → terminal → git → editing → ai → lang/*.
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
require("manu.lang.lua")
