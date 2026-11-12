-- Lint : nvim-lint lance les linters externes (PHPStan, ESLint, hadolint…) et publie leurs
-- résultats comme diagnostics. Les fichiers de langage remplissent
-- require("lint").linters_by_ft ; ce module déclenche le lint à l'ouverture, à
-- l'enregistrement et en quittant l'insertion.

vim.pack.add({ "https://github.com/mfussenegger/nvim-lint" }, { confirm = false })

local lint = require("lint")
lint.linters_by_ft = lint.linters_by_ft or {}

local timer = vim.uv.new_timer()
vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost", "InsertLeave" }, {
  group = vim.api.nvim_create_augroup("manu_lint", { clear = true }),
  callback = function()
    -- Anti-rebond : un seul lint pour une rafale d'événements.
    timer:stop()
    timer:start(100, 0, vim.schedule_wrap(function()
      lint.try_lint()
    end))
  end,
})
