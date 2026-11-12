-- Formatage : conform.nvim (un formateur par type de fichier, appelé à l'enregistrement).
-- Règle : on ne formate à l'enregistrement QUE si le projet contient la config du formateur
-- (stylua.toml, .prettierrc, .php-cs-fixer.php…). Chaque formateur concerné déclare une
-- `condition` qui appelle project_has(). Les fichiers de langage remplissent
-- require("conform").formatters_by_ft.
--
-- Bascules (touches LazyVim) : <leader>uf = global (vim.g.autoformat),
-- <leader>uF = buffer (vim.b.autoformat, prioritaire sur le global quand il est posé).

vim.pack.add({ { src = "https://github.com/stevearc/conform.nvim", version = vim.version.range("9.*") } }, {
  confirm = false,
})

local M = {}

--- Vrai si l'un des fichiers `names` existe en remontant depuis le buffer.
---@param names string[]
---@param bufnr integer
---@return boolean
function M.project_has(names, bufnr)
  return vim.fs.root(bufnr, names) ~= nil
end

--- Le formatage à l'enregistrement est-il actif pour ce buffer ?
---@param bufnr integer
function M.enabled(bufnr)
  local b = vim.b[bufnr].autoformat
  if b ~= nil then
    return b
  end
  return vim.g.autoformat ~= false
end

require("conform").setup({
  formatters_by_ft = {},
  default_format_opts = { lsp_format = "never" },
  format_on_save = function(bufnr)
    if not M.enabled(bufnr) then
      return nil
    end
    return { timeout_ms = 3000, lsp_format = "never" }
  end,
  notify_no_formatters = false,
})

vim.g.autoformat = true

local map = vim.keymap.set
map({ "n", "x" }, "<leader>cf", function()
  require("conform").format({ timeout_ms = 3000, lsp_format = "fallback" })
end, { desc = "Formater (fichier ou sélection)" })
map({ "n", "x" }, "<leader>cF", function()
  require("conform").format({ formatters = { "injected" }, timeout_ms = 3000 })
end, { desc = "Formater les langages injectés" })
map("n", "<leader>uf", function()
  vim.g.autoformat = vim.g.autoformat == false
  vim.notify((vim.g.autoformat and "Activé" or "Désactivé") .. " : formatage à l'enregistrement (global)")
end, { desc = "Basculer le formatage auto (global)" })
map("n", "<leader>uF", function()
  local on = not M.enabled(0)
  vim.b.autoformat = on
  vim.notify((on and "Activé" or "Désactivé") .. " : formatage à l'enregistrement (buffer)")
end, { desc = "Basculer le formatage auto (buffer)" })

return M
