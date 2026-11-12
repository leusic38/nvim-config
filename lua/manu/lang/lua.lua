-- Langage Lua (et config Neovim). MODÈLE des fichiers de langage, dans cet ordre :
--   1. vim.pack.add({ … })                          plugins propres au langage (aucun ici)
--   2. require("manu.mason").ensure({ … })          serveurs, formateurs, linters à installer
--   3. vim.lsp.config(<serveur>, { … })              surcharge (ou fichier lsp/<serveur>.lua)
--   4. vim.lsp.enable({ … })                        serveurs actifs
--   5. require("conform").formatters_by_ft[ft]      formateurs (Task 6 : manu.format)
--   6. require("lint").linters_by_ft[ft]            linters (Task 6 : manu.lint)
--   7. require("manu.treesitter").install({ … })    parsers
-- Pas de lazydev : lua_ls reçoit $VIMRUNTIME en bibliothèque, ce qui suffit à connaître vim.*.

require("manu.mason").ensure({ "lua-language-server", "stylua" })

vim.lsp.config("lua_ls", {
  settings = {
    Lua = {
      runtime = { version = "LuaJIT" },
      diagnostics = { globals = { "vim" } },
      workspace = { checkThirdParty = false, library = { vim.env.VIMRUNTIME } },
      hint = { enable = true },
      telemetry = { enable = false },
    },
  },
})
vim.lsp.enable({ "lua_ls" })

require("manu.treesitter").install({ "lua", "luadoc" })
