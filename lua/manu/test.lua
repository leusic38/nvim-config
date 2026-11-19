-- Tests : neotest lance et affiche les tests (fichier, test au curseur, résumé, sortie), quel
-- que soit le framework. nvim-nio : bibliothèque asynchrone requise par neotest.
--
-- Chaque fichier de langage enregistre ses adaptateurs avec add_adapter() ; neotest.setup
-- est appelé une seule fois, au VimEnter, avec tous les adaptateurs (neotest n'accepte
-- pas d'en ajouter après coup). Seule exception au « rien de différé » de la config.
-- Raccourcis : par langage (buffer), ex. <leader>pt… en PHP, <leader>jt… en JS.

vim.pack.add({
  "https://github.com/nvim-neotest/nvim-nio",
  "https://github.com/nvim-neotest/neotest",
  "https://github.com/olimorris/neotest-phpunit",
  "https://github.com/V13Axel/neotest-pest",
}, { confirm = false })

local M = {}

local adapters = {}
local started = false

--- Enregistre un adaptateur (table renvoyée par require("neotest-xxx")(opts)).
function M.add_adapter(adapter)
  table.insert(adapters, adapter)
  if started then
    vim.notify("neotest déjà démarré : adaptateur ignoré", vim.log.levels.WARN)
  end
end

function M.adapters()
  return adapters
end

vim.api.nvim_create_autocmd("VimEnter", {
  group = vim.api.nvim_create_augroup("manu_test", { clear = true }),
  once = true,
  callback = function()
    started = true
    require("neotest").setup({
      adapters = adapters,
      output = { open_on_run = false },
      quickfix = { open = false },
      floating = { border = "rounded" },
      status = { virtual_text = true },
    })
  end,
})

return M
