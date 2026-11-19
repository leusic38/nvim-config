-- Filtres de faux positifs d'Intelephense, repris de l'ancienne lua/config/autocmds.lua.
-- Approche DiagnosticChanged : on retire les diagnostics après que Neovim les a stockés,
-- sans toucher aux handlers LSP (cf. mémoire : vim.lsp.handlers ne marche plus en 0.12).
--   Laravel : méthodes de façades « non statiques », helpers globaux inconnus.
--   Symfony : méthodes de test du framework, dd/dump…, P1013 sur getRepository(...)->méthode().

local M = {}

local laravel_facade_methods = {
  "where", "find", "create", "update", "delete", "get", "first", "with",
  "select", "join", "orderBy", "groupBy", "having", "take", "skip",
  "count", "sum", "avg", "min", "max", "paginate", "latest", "oldest",
  "findOrFail", "firstOrFail", "firstOrCreate", "updateOrCreate",
  "whereIn", "whereNull", "whereNotNull", "whereBetween",
  "insert", "insertOrIgnore", "truncate", "forceDelete", "restore",
  "all", "pluck", "value", "chunk", "each", "lazy", "cursor",
  "increment", "decrement", "touch",
}

local laravel_helpers = {
  "request", "config", "route", "auth", "session", "cache", "view",
  "redirect", "response", "abort", "app", "bcrypt", "collect", "env",
  "event", "info", "logger", "old", "resolve", "url", "asset", "trans",
  "__", "dispatch", "optional", "now", "today", "validator", "storage",
  "cookie", "dd", "dump", "tap", "filled", "blank", "rescue", "retry",
  "value", "with", "abort_if", "abort_unless", "throw_if", "throw_unless",
  "report", "back", "action", "mix", "secure_url", "secure_asset",
  "policy", "gate", "broadcast", "queue",
}

local symfony_test_methods = {
  "createClient", "bootKernel", "getContainer", "createKernel",
  "ensureKernelShutdown", "tearDownAfterClass", "setUpBeforeClass",
  "assertResponseIsSuccessful", "assertResponseStatusCodeSame",
  "assertResponseRedirects", "assertRouteSame",
  "assertPageTitleContains", "assertPageTitleSame",
  "assertSelectorExists", "assertSelectorNotExists",
  "assertSelectorTextContains", "assertSelectorTextSame",
  "assertEmailCount", "assertQueuedEmailCount",
  "assertBrowserCookieValueSame", "assertBrowserHasCookie",
}

local symfony_global_functions = { "dd", "dump", "ddd", "t", "u", "b", "s" }

-- Retourne false si le diagnostic doit être supprimé (faux positif).
-- Reçoit un diagnostic au format Neovim (lnum, code, message, ...).
function M._should_hide(diag, bufnr, framework)
  local msg = diag.message

  if framework == "laravel" then
    if msg:find("Non static method") or msg:find("non%-static") then
      for _, m in ipairs(laravel_facade_methods) do
        if msg:find(m, 1, true) then return true end
      end
    end
    if msg:find("Undefined") then
      for _, h in ipairs(laravel_helpers) do
        if msg:find("'" .. h .. "'", 1, true) then return true end
      end
    end
  end

  if framework == "symfony" then
    if msg:find("Non static method") or msg:find("non%-static") then
      for _, m in ipairs(symfony_test_methods) do
        if msg:find(m, 1, true) then return true end
      end
    end
    if msg:find("Undefined function") then
      for _, f in ipairs(symfony_global_functions) do
        if msg:find("'" .. f .. "'", 1, true) then return true end
      end
    end
    -- Doctrine : getRepository(Entity::class)->repoMethod() → P1013 faux positif.
    -- diag.lnum est 0-indexé (format Neovim), identique à nvim_buf_get_lines.
    if diag.code == "P1013" and vim.api.nvim_buf_is_loaded(bufnr) then
      local lines = vim.api.nvim_buf_get_lines(bufnr, math.max(0, diag.lnum - 1), diag.lnum + 1, false)
      for _, line in ipairs(lines) do
        if line:find("getRepository", 1, true) then return true end
      end
    end
  end

  return false
end

local _filtering = {}

function M.setup()
  vim.api.nvim_create_autocmd("DiagnosticChanged", {
    group = vim.api.nvim_create_augroup("manu_php_filters", { clear = true }),
    callback = function(args)
      local bufnr = args.buf
      if _filtering[bufnr] then return end
      if vim.bo[bufnr].filetype ~= "php" then return end

      local framework = require("manu.project").framework(bufnr)
      if not framework then return end

      local clients = vim.lsp.get_clients({ bufnr = bufnr, name = "intelephense" })
      if #clients == 0 then return end

      local ok, ns_id = pcall(vim.lsp.diagnostic.get_namespace, clients[1].id)
      if not ok then return end

      local diags = vim.diagnostic.get(bufnr, { namespace = ns_id })
      local filtered = vim.tbl_filter(function(d)
        return not M._should_hide(d, bufnr, framework)
      end, diags)

      if #filtered == #diags then return end

      _filtering[bufnr] = true
      vim.diagnostic.set(ns_id, bufnr, filtered)
      _filtering[bufnr] = false
    end,
  })
end

return M
