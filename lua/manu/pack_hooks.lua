-- Hooks de vim.pack (builds après installation ou mise à jour d'un plugin).
-- Doit être requis AVANT le premier vim.pack.add (cf. :h vim.pack-events), sinon
-- l'installation initiale (ou depuis le lockfile) passe sans déclencher les hooks.
--
-- Usage dans un module : require("manu.pack_hooks").register("nvim-treesitter", function(ev) … end)
-- ev.data = { kind = "install"|"update"|"delete", spec = …, path = …, active = … }

local M = {}

---@type table<string, fun(ev: table)[]>
local hooks = {}

---@param name string nom du plugin (spec.name)
---@param fn fun(ev: table)
function M.register(name, fn)
  hooks[name] = hooks[name] or {}
  table.insert(hooks[name], fn)
end

vim.api.nvim_create_autocmd("PackChanged", {
  group = vim.api.nvim_create_augroup("manu_pack_hooks", { clear = true }),
  callback = function(ev)
    for _, fn in ipairs(hooks[ev.data.spec.name] or {}) do
      local ok, err = pcall(fn, ev)
      if not ok then
        vim.notify(("Hook %s : %s"):format(ev.data.spec.name, err), vim.log.levels.ERROR)
      end
    end
  end,
})

return M
