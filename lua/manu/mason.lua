-- Mason : installe les outils externes (serveurs LSP, formateurs, linters) hors du système.
-- Pourquoi : les mêmes versions sur toutes les machines, sans passer par pacman/npm/composer.
-- Les fichiers de langage appellent require("manu.mason").ensure({ … }).

vim.pack.add(
  { { src = "https://github.com/mason-org/mason.nvim", version = vim.version.range("2.*") } },
  { confirm = false }
)

require("mason").setup({ ui = { border = "rounded" } })

local M = {}

--- Installe en tâche de fond les paquets Mason absents. Jamais bloquant : hors ligne,
--- le rafraîchissement du registre échoue et rien n'est tenté.
---@param pkgs string[]
function M.ensure(pkgs)
  local registry = require("mason-registry")
  registry.refresh(function(success)
    if success == false then
      return
    end
    for _, name in ipairs(pkgs) do
      local ok, pkg = pcall(registry.get_package, name)
      if not ok then
        vim.schedule(function()
          vim.notify("Mason : paquet inconnu " .. name, vim.log.levels.WARN)
        end)
      elseif not pkg:is_installed() and not pkg:is_installing() then
        pkg:install()
      end
    end
  end)
end

return M
