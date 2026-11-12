-- Treesitter : coloration, indentation et plis à partir de l'arbre syntaxique.
--
-- nvim-treesitter (branche main) : installe/compile les parsers et fournit les requêtes.
--   Neovim 0.12 fait le reste nativement (vim.treesitter.start, foldexpr, an/in en visuel).
-- nvim-treesitter-textobjects    : déplacements par fonction/classe/paramètre (]f [f ]c …),
--   retenus au tri ; les objets af/if… viennent de mini.ai (Task 9).

local hooks = require("manu.pack_hooks")
hooks.register("nvim-treesitter", function(ev)
  if ev.data.kind == "update" then
    if not ev.data.active then
      vim.cmd.packadd("nvim-treesitter")
    end
    vim.cmd("TSUpdate")
  end
end)

vim.pack.add({
  { src = "https://github.com/nvim-treesitter/nvim-treesitter", version = "main" },
  { src = "https://github.com/nvim-treesitter/nvim-treesitter-textobjects", version = "main" },
}, { confirm = false })

local M = {}

--- Installe des parsers manquants (asynchrone, ne bloque pas le démarrage).
---@param langs string[]
function M.install(langs)
  local installed = require("nvim-treesitter").get_installed()
  local missing = vim.tbl_filter(function(l)
    return not vim.tbl_contains(installed, l)
  end, langs)
  if #missing > 0 then
    require("nvim-treesitter").install(missing)
  end
end

M.install({
  "lua",
  "vim",
  "vimdoc",
  "query",
  "markdown",
  "markdown_inline",
  "bash",
  "json",
  "yaml",
  "regex",
  "diff",
  "gitcommit",
})

require("nvim-treesitter-textobjects").setup({
  move = { set_jumps = true },
})

-- Déplacements par objet (buffer-local, seulement si le langage a des requêtes textobjects).
local moves = {
  goto_next_start = { ["]f"] = "@function.outer", ["]c"] = "@class.outer", ["]a"] = "@parameter.inner" },
  goto_next_end = { ["]F"] = "@function.outer", ["]C"] = "@class.outer", ["]A"] = "@parameter.inner" },
  goto_previous_start = { ["[f"] = "@function.outer", ["[c"] = "@class.outer", ["[a"] = "@parameter.inner" },
  goto_previous_end = { ["[F"] = "@function.outer", ["[C"] = "@class.outer", ["[A"] = "@parameter.inner" },
}
local labels = {
  ["@function.outer"] = "fonction",
  ["@class.outer"] = "classe",
  ["@parameter.inner"] = "paramètre",
}
local verbs = {
  goto_next_start = "Début de %s suivant(e)",
  goto_next_end = "Fin de %s suivant(e)",
  goto_previous_start = "Début de %s précédent(e)",
  goto_previous_end = "Fin de %s précédent(e)",
}

vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("manu_treesitter", { clear = true }),
  callback = function(ev)
    local lang = vim.treesitter.language.get_lang(ev.match)
    if not lang or not pcall(vim.treesitter.start, ev.buf, lang) then
      return
    end
    vim.bo[ev.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
    if not vim.treesitter.query.get(lang, "textobjects") then
      return
    end
    local move = require("nvim-treesitter-textobjects.move")
    for method, keys in pairs(moves) do
      for key, query in pairs(keys) do
        -- [c/]c restent au diff quand la fenêtre est en mode diff.
        if not (vim.wo.diff and key:find("[cC]")) then
          vim.keymap.set({ "n", "x", "o" }, key, function()
            move[method](query, "textobjects")
          end, { buffer = ev.buf, desc = verbs[method]:format(labels[query]) })
        end
      end
    end
  end,
})

return M
