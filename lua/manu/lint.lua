-- Lint : nvim-lint lance les linters externes (PHPStan, ESLint, hadolint…) et publie leurs
-- résultats comme diagnostics. Les fichiers de langage remplissent
-- require("lint").linters_by_ft, et peuvent régler un linter avec M.configure :
--   events    : événements qui le déclenchent (défaut : ouverture, enregistrement, sortie
--               d'insertion ; PHPStan, lent, ne tourne qu'à l'enregistrement) ;
--   condition : fonction(bufnr) → false pour ne pas le lancer (config absente du projet,
--               conteneur arrêté…).

vim.pack.add({ "https://github.com/mfussenegger/nvim-lint" }, { confirm = false })

local lint = require("lint")
lint.linters_by_ft = lint.linters_by_ft or {}

local M = {}

local DEFAULT_EVENTS = { "BufWritePost", "BufReadPost", "InsertLeave" }

---@type table<string, { events?: string[], condition?: fun(bufnr: integer): boolean }>
local settings = {}

---@param name string nom du linter (clé de require("lint").linters)
---@param opts { events?: string[], condition?: fun(bufnr: integer): boolean }
function M.configure(name, opts)
  settings[name] = opts
end

--- Linters à lancer pour ce buffer et cet événement.
function M.names_for(bufnr, event)
  local names = {}
  for _, name in ipairs(lint._resolve_linter_by_ft(vim.bo[bufnr].filetype)) do
    local s = settings[name] or {}
    if vim.tbl_contains(s.events or DEFAULT_EVENTS, event) and (not s.condition or s.condition(bufnr)) then
      table.insert(names, name)
    end
  end
  return names
end

local timer = vim.uv.new_timer()
local pending = {}
vim.api.nvim_create_autocmd(DEFAULT_EVENTS, {
  group = vim.api.nvim_create_augroup("manu_lint", { clear = true }),
  callback = function(ev)
    -- Anti-rebond : un seul lint pour une rafale d'événements, avec l'union des linters dus.
    for _, name in ipairs(M.names_for(ev.buf, ev.event)) do
      pending[name] = true
    end
    timer:stop()
    timer:start(100, 0, vim.schedule_wrap(function()
      local names = vim.tbl_keys(pending)
      pending = {}
      if #names > 0 then
        lint.try_lint(names)
      end
    end))
  end,
})

return M
