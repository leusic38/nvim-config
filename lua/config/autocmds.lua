-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- ─── Filtres de diagnostics Intelephense ─────────────────────────────────────
-- Approche DiagnosticChanged : on modifie les diagnostics après que Neovim les
-- a stockés, sans toucher aux handlers LSP (incompatible avec Neovim 0.10+).

local function get_framework(bufnr)
  local dirs = { vim.fn.getcwd() }
  if bufnr and bufnr > 0 then
    local filepath = vim.api.nvim_buf_get_name(bufnr)
    if filepath ~= "" then
      local dir = vim.fn.fnamemodify(filepath, ":h")
      for _ = 1, 10 do
        table.insert(dirs, dir)
        local parent = vim.fn.fnamemodify(dir, ":h")
        if parent == dir then break end
        dir = parent
      end
    end
  end
  for _, dir in ipairs(dirs) do
    if vim.fn.filereadable(dir .. "/artisan") == 1 then
      return "laravel"
    elseif vim.fn.filereadable(dir .. "/bin/console") == 1 then
      return "symfony"
    end
  end
  return nil
end

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
local function should_hide(diag, bufnr, framework)
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

vim.api.nvim_create_autocmd("DiagnosticChanged", {
  callback = function(args)
    local bufnr = args.buf
    if _filtering[bufnr] then return end
    if vim.bo[bufnr].filetype ~= "php" then return end

    local framework = get_framework(bufnr)
    if not framework then return end

    local clients = vim.lsp.get_clients({ bufnr = bufnr, name = "intelephense" })
    if #clients == 0 then return end

    local ok, ns_id = pcall(vim.lsp.diagnostic.get_namespace, clients[1].id)
    if not ok then return end

    local diags = vim.diagnostic.get(bufnr, { namespace = ns_id })
    local filtered = vim.tbl_filter(function(d)
      return not should_hide(d, bufnr, framework)
    end, diags)

    if #filtered == #diags then return end

    _filtering[bufnr] = true
    vim.diagnostic.set(ns_id, bufnr, filtered)
    _filtering[bufnr] = false
  end,
})

-- Load PHP-specific keymaps and settings for PHP files
vim.api.nvim_create_autocmd("FileType", {
  pattern = "php",
  callback = function()
    require("config.php-keymaps")
    -- Auto-lint on save
    vim.api.nvim_create_autocmd("BufWritePost", {
      buffer = 0,
      callback = function()
        require("lint").try_lint()
      end,
    })
  end,
})

-- Load Terraform-specific keymaps and settings for Terraform files
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "terraform", "tf", "hcl" },
  callback = function()
    require("config.terraform-keymaps")
    -- Auto-lint on save
    vim.api.nvim_create_autocmd("BufWritePost", {
      buffer = 0,
      callback = function()
        require("lint").try_lint()
      end,
    })
  end,
})

-- Load Markdown-specific keymaps and settings for Markdown files
vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function()
    require("config.markdown-keymaps")
    -- Auto-lint on save
    vim.api.nvim_create_autocmd("BufWritePost", {
      buffer = 0,
      callback = function()
        require("lint").try_lint()
      end,
    })
  end,
})

-- Load JavaScript/TypeScript/Vue keymaps
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "javascript", "typescript", "javascriptreact", "typescriptreact", "vue" },
  callback = function()
    require("config.js-keymaps")
  end,
})
