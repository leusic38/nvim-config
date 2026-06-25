-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

vim.g.lazyvim_php_lsp = "intelephense"

-- Spell checking configuration
vim.opt.spelllang = { "en", "fr" } -- Support anglais et français
vim.opt.spell = false -- Désactivé par défaut, activer avec <leader>us
