-- Markdown specific keymaps
-- Ce fichier est chargé automatiquement par autocmds.lua pour les fichiers markdown
local map = vim.keymap.set

-- Format avec prettier
map("n", "<leader>mf", function()
  local conform = require("conform")
  conform.format({ async = true, lsp_fallback = true })
end, { buffer = 0, desc = "MD: Format avec Prettier" })

-- Lint avec markdownlint-cli2
map("n", "<leader>ml", function()
  require("lint").try_lint()
end, { buffer = 0, desc = "MD: Lint avec markdownlint" })

-- Format + lint ensemble (corrige les warnings automatiquement)
map("n", "<leader>mc", function()
  local conform = require("conform")
  conform.format({ async = true, lsp_fallback = true }, function()
    vim.defer_fn(function()
      require("lint").try_lint()
    end, 200)
  end)
end, { buffer = 0, desc = "MD: Corriger tous les problèmes" })

-- Actions de code LSP
map("n", "<leader>ma", vim.lsp.buf.code_action, { buffer = 0, desc = "MD: Actions de code" })
