-- Outils d'édition retenus au tri (docs/tri.md), chacun avec sa raison d'être :
--
-- flash.nvim         : sauter n'importe où en 2-3 touches (s), sélection par nœud Treesitter (S, <C-Space>).
-- mini.ai            : objets textuels étendus (af/if fonction, ac classe, aa argument, a"…, an/al suivant/précédent).
-- mini.pairs         : ferme automatiquement (), [], {}, guillemets.
-- grug-far.nvim      : rechercher/remplacer dans tout le projet, avec aperçu (<leader>sr).
-- trouble.nvim       : listes (diagnostics, symboles, quickfix, todo) dans un panneau navigable.
-- todo-comments.nvim : surligne TODO/FIX/NOTE… et permet de les lister/parcourir.
-- persistence.nvim   : sessions par dossier (buffers, fenêtres) restaurables.
-- refactoring.nvim   : extraire fonction/variable/bloc, inliner (raccourcis perso <leader>R…).
-- nvim-ts-autotag    : ferme/renomme les balises HTML/Vue/Twig automatiquement.
-- plenary.nvim       : bibliothèque requise par todo-comments.
-- async.nvim         : requis par refactoring.nvim sous Neovim 0.12 (inutile en 0.13).
--
-- Non repris : ts-comments.nvim (gc natif de Neovim gère les langages injectés).

vim.pack.add({
  "https://github.com/nvim-lua/plenary.nvim",
  { src = "https://github.com/folke/flash.nvim", version = vim.version.range("2.*") },
  { src = "https://github.com/nvim-mini/mini.ai", version = vim.version.range("0.*") },
  { src = "https://github.com/nvim-mini/mini.pairs", version = vim.version.range("0.*") },
  "https://github.com/MagicDuck/grug-far.nvim",
  { src = "https://github.com/folke/trouble.nvim", version = vim.version.range("3.*") },
  { src = "https://github.com/folke/todo-comments.nvim", version = vim.version.range("1.*") },
  { src = "https://github.com/folke/persistence.nvim", version = vim.version.range("3.*") },
  "https://github.com/lewis6991/async.nvim",
  "https://github.com/ThePrimeagen/refactoring.nvim",
  "https://github.com/windwp/nvim-ts-autotag",
}, { confirm = false })

local map = vim.keymap.set

-- ─── flash ─────────────────────────────────────────────────────────────────
local flash = require("flash")
flash.setup({})
map({ "n", "x", "o" }, "s", function()
  flash.jump()
end, { desc = "Flash : sauter" })
map({ "n", "x", "o" }, "S", function()
  flash.treesitter()
end, { desc = "Flash : nœud Treesitter" })
map("o", "r", function()
  flash.remote()
end, { desc = "Flash à distance" })
map({ "o", "x" }, "R", function()
  flash.treesitter_search()
end, { desc = "Flash : recherche Treesitter" })
map("c", "<c-s>", function()
  flash.toggle()
end, { desc = "Basculer Flash dans la recherche" })
map({ "n", "x", "o" }, "<c-space>", function()
  flash.treesitter({ actions = { ["<c-space>"] = "next", ["<BS>"] = "prev" } })
end, { desc = "Sélection incrémentale (Treesitter)" })

-- ─── mini.ai ───────────────────────────────────────────────────────────────
local ai = require("mini.ai")
ai.setup({
  n_lines = 500,
  custom_textobjects = {
    o = ai.gen_spec.treesitter({
      a = { "@block.outer", "@conditional.outer", "@loop.outer" },
      i = { "@block.inner", "@conditional.inner", "@loop.inner" },
    }),
    f = ai.gen_spec.treesitter({ a = "@function.outer", i = "@function.inner" }),
    c = ai.gen_spec.treesitter({ a = "@class.outer", i = "@class.inner" }),
    t = { "<([%p%w]-)%f[^<%w][^<>]->.-</%1>", "^<.->().*()</[^/]->$" },
    d = { "%f[%d]%d+" },
    e = {
      { "%u[%l%d]+%f[^%l%d]", "%f[%S][%l%d]+%f[^%l%d]", "%f[%P][%l%d]+%f[^%l%d]", "^[%l%d]+%f[^%l%d]" },
      "^().*()$",
    },
    g = function() -- tout le buffer
      local last = vim.fn.line("$")
      return { from = { line = 1, col = 1 }, to = { line = last, col = math.max(vim.fn.getline(last):len(), 1) } }
    end,
    u = ai.gen_spec.function_call(),
    U = ai.gen_spec.function_call({ name_pattern = "[%w_]" }),
  },
})

-- ─── mini.pairs ────────────────────────────────────────────────────────────
require("mini.pairs").setup({
  modes = { insert = true, command = true, terminal = false },
  skip_next = [=[[%w%%%'%[%"%.%`%$]]=],
  skip_ts = { "string" },
  skip_unbalanced = true,
  markdown = true,
})
map("n", "<leader>up", function()
  vim.g.minipairs_disable = not vim.g.minipairs_disable
  vim.notify((vim.g.minipairs_disable and "Désactivé" or "Activé") .. " : fermeture auto des paires")
end, { desc = "Basculer la fermeture auto des paires" })

-- ─── grug-far ──────────────────────────────────────────────────────────────
require("grug-far").setup({ headerMaxWidth = 80 })
map({ "n", "x" }, "<leader>sr", function()
  local ext = vim.bo.buftype == "" and vim.fn.expand("%:e")
  require("grug-far").open({
    transient = true,
    prefills = { filesFilter = ext and ext ~= "" and "*." .. ext or nil },
  })
end, { desc = "Rechercher et remplacer (projet)" })

-- ─── trouble ───────────────────────────────────────────────────────────────
local trouble = require("trouble")
trouble.setup({ modes = { lsp = { win = { position = "right" } } } })
map("n", "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", { desc = "Diagnostics (Trouble)" })
map("n", "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", { desc = "Diagnostics du buffer (Trouble)" })
map("n", "<leader>cs", "<cmd>Trouble symbols toggle<cr>", { desc = "Symboles (Trouble)" })
map("n", "<leader>cS", "<cmd>Trouble lsp toggle<cr>", { desc = "Références/définitions LSP (Trouble)" })
map("n", "<leader>xL", "<cmd>Trouble loclist toggle<cr>", { desc = "Liste locale (Trouble)" })
map("n", "<leader>xQ", "<cmd>Trouble qflist toggle<cr>", { desc = "Quickfix (Trouble)" })
-- [q / ]q : élément suivant dans Trouble s'il est ouvert, sinon dans la quickfix.
local function trouble_or_qf(dir)
  return function()
    if trouble.is_open() then
      trouble[dir]({ skip_groups = true, jump = true })
    else
      local ok, err = pcall(dir == "next" and vim.cmd.cnext or vim.cmd.cprev)
      if not ok then
        vim.notify(err, vim.log.levels.ERROR)
      end
    end
  end
end
map("n", "[q", trouble_or_qf("prev"), { desc = "Élément précédent (Trouble/quickfix)" })
map("n", "]q", trouble_or_qf("next"), { desc = "Élément suivant (Trouble/quickfix)" })

-- ─── todo-comments ─────────────────────────────────────────────────────────
local todo = require("todo-comments")
todo.setup({})
map("n", "]t", function()
  todo.jump_next()
end, { desc = "TODO suivant" })
map("n", "[t", function()
  todo.jump_prev()
end, { desc = "TODO précédent" })
map("n", "<leader>xt", "<cmd>Trouble todo toggle<cr>", { desc = "TODO (Trouble)" })
map("n", "<leader>xT", "<cmd>Trouble todo toggle filter = {tag = {TODO,FIX,FIXME}}<cr>", { desc = "TODO/FIX/FIXME (Trouble)" })
map("n", "<leader>st", "<cmd>TodoFzfLua<cr>", { desc = "TODO (fzf)" })
map("n", "<leader>sT", "<cmd>TodoFzfLua keywords=TODO,FIX,FIXME<cr>", { desc = "TODO/FIX/FIXME (fzf)" })

-- ─── persistence ───────────────────────────────────────────────────────────
local persistence = require("persistence")
persistence.setup({})
map("n", "<leader>qs", function()
  persistence.load()
end, { desc = "Restaurer la session (dossier)" })
map("n", "<leader>qS", function()
  persistence.select()
end, { desc = "Choisir une session" })
map("n", "<leader>ql", function()
  persistence.load({ last = true })
end, { desc = "Restaurer la dernière session" })
map("n", "<leader>qd", function()
  persistence.stop()
end, { desc = "Ne pas enregistrer la session" })

-- ─── refactoring (touches perso de l'ancienne lua/plugins/refactoring.lua) ──
-- L'API actuelle n'a plus « Extract Block » : <leader>Rb et <leader>RF ne sont pas repris.
local refactoring = require("refactoring")
refactoring.setup({})
local function refactor(fn)
  return function()
    return refactoring[fn]()
  end
end
map({ "n", "x" }, "<leader>Rm", function()
  refactoring.select_refactor()
end, { desc = "Refactoring : menu" })
map("x", "<leader>Re", refactor("extract_func"), { expr = true, desc = "Refactoring : extraire une fonction" })
map("x", "<leader>Rf", refactor("extract_func_to_file"), { expr = true, desc = "Refactoring : extraire une fonction dans un fichier" })
map("x", "<leader>Rv", refactor("extract_var"), { expr = true, desc = "Refactoring : extraire une variable" })
map({ "n", "x" }, "<leader>Ri", refactor("inline_var"), { expr = true, desc = "Refactoring : inliner la variable" })

-- ─── nvim-ts-autotag ───────────────────────────────────────────────────────
require("nvim-ts-autotag").setup({})
