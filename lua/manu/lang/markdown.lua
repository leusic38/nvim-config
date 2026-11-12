-- Langage Markdown (suit le modèle de lang/lua.lua).
--
-- render-markdown.nvim : affiche le Markdown mis en forme dans le buffer (titres, listes,
--   tableaux, cases à cocher, blocs de code) ; la ligne en cours d'édition reste brute.
-- Aperçu navigateur : <leader>H (manu.keymaps, via le script mdview).
-- Lint/format markdownlint + Prettier : avec le plan JS (Prettier) — pas encore ici.

vim.pack.add({
  { src = "https://github.com/MeanderingProgrammer/render-markdown.nvim", version = vim.version.range("8.*") },
}, { confirm = false })

require("render-markdown").setup({
  file_types = { "markdown" },
  completions = { blink = { enabled = true } },
})

vim.keymap.set("n", "<leader>um", function()
  require("render-markdown").toggle()
  vim.notify((require("render-markdown.state").enabled and "Activé" or "Désactivé") .. " : rendu Markdown")
end, { desc = "Basculer le rendu Markdown" })

require("manu.treesitter").install({ "markdown", "markdown_inline", "html", "latex", "yaml" })
