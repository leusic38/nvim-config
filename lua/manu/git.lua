-- Git dans l'éditeur.
-- gitsigns.nvim : marques de modification dans la marge, navigation et actions par hunk.
-- diffview.nvim : vue diff/historique sur plusieurs fichiers (config de l'ancienne git.lua).
-- Historique, statut, stash : fzf-lua. Lazygit : manu.terminal.

vim.pack.add({
  { src = "https://github.com/lewis6991/gitsigns.nvim", version = vim.version.range("1.*") },
  "https://github.com/sindrets/diffview.nvim",
}, { confirm = false })

local map = vim.keymap.set

require("gitsigns").setup({
  signs = {
    add = { text = "▎" },
    change = { text = "▎" },
    delete = { text = "" },
    topdelete = { text = "" },
    changedelete = { text = "▎" },
    untracked = { text = "▎" },
  },
  signs_staged = {
    add = { text = "▎" },
    change = { text = "▎" },
    delete = { text = "" },
    topdelete = { text = "" },
    changedelete = { text = "▎" },
  },
  on_attach = function(buf)
    local gs = require("gitsigns")
    local function bmap(mode, lhs, rhs, desc)
      map(mode, lhs, rhs, { buffer = buf, desc = desc, silent = true })
    end
    bmap("n", "]h", function()
      if vim.wo.diff then
        vim.cmd.normal({ "]c", bang = true })
      else
        gs.nav_hunk("next")
      end
    end, "Hunk suivant")
    bmap("n", "[h", function()
      if vim.wo.diff then
        vim.cmd.normal({ "[c", bang = true })
      else
        gs.nav_hunk("prev")
      end
    end, "Hunk précédent")
    bmap("n", "]H", function()
      gs.nav_hunk("last")
    end, "Dernier hunk")
    bmap("n", "[H", function()
      gs.nav_hunk("first")
    end, "Premier hunk")
    bmap({ "n", "x" }, "<leader>ghs", ":Gitsigns stage_hunk<CR>", "Indexer le hunk")
    bmap({ "n", "x" }, "<leader>ghr", ":Gitsigns reset_hunk<CR>", "Annuler le hunk")
    bmap("n", "<leader>ghS", gs.stage_buffer, "Indexer le fichier")
    bmap("n", "<leader>ghu", gs.undo_stage_hunk, "Désindexer le hunk")
    bmap("n", "<leader>ghR", gs.reset_buffer, "Annuler les modifications du fichier")
    bmap("n", "<leader>ghp", gs.preview_hunk_inline, "Aperçu du hunk")
    bmap("n", "<leader>ghb", function()
      gs.blame_line({ full = true })
    end, "Blame de la ligne")
    bmap("n", "<leader>ghB", function()
      gs.blame()
    end, "Blame du fichier")
    bmap("n", "<leader>ghd", gs.diffthis, "Diff du fichier")
    bmap("n", "<leader>ghD", function()
      gs.diffthis("~")
    end, "Diff du fichier (~)")
    bmap({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", "Hunk (objet)")
  end,
})

require("diffview").setup({
  -- Panneau de gauche : seulement les fichiers suivis (modifiés / indexés). Pour voir les
  -- non suivis : :DiffviewOpen --untracked-files=all
  default_args = { DiffviewOpen = { "--untracked-files=no" } },
  hooks = {
    diff_buf_read = function()
      vim.opt_local.wrap = false
    end,
  },
})

local function fzf(cmd, opts)
  return function()
    require("fzf-lua")[cmd](opts and opts() or {})
  end
end
local root = require("manu.root")

map("n", "<leader>gd", "<cmd>DiffviewOpen<cr>", { desc = "Diffview (HEAD)" })
map("n", "<leader>gD", "<cmd>DiffviewClose<cr>", { desc = "Fermer Diffview" })
map("n", "<leader>gF", "<cmd>DiffviewFileHistory %<cr>", { desc = "Historique du fichier (Diffview)" })
map("n", "<leader>gs", fzf("git_status"), { desc = "Statut git" })
map("n", "<leader>gS", fzf("git_stash"), { desc = "Stash git" })
map("n", "<leader>gc", fzf("git_commits"), { desc = "Commits" })
map("n", "<leader>gl", fzf("git_commits", function()
  return { cwd = root() }
end), { desc = "Commits (racine du projet)" })
map("n", "<leader>gL", fzf("git_commits", function()
  return { cwd = vim.uv.cwd() }
end), { desc = "Commits (dossier courant)" })
map("n", "<leader>gf", fzf("git_bcommits"), { desc = "Historique du fichier" })
map("n", "<leader>gb", function()
  require("gitsigns").blame_line({ full = true })
end, { desc = "Blame de la ligne" })

-- Message de commit : <leader>gc choisit un type Conventional Commits et l'insère en début de
-- ligne (remplace telescope-cc).
local cc_types = {
  { "feat", "nouvelle fonctionnalité" },
  { "fix", "correction de bug" },
  { "docs", "documentation" },
  { "style", "mise en forme, sans effet sur le code" },
  { "refactor", "restructuration sans changement de comportement" },
  { "perf", "performance" },
  { "test", "tests" },
  { "build", "build, dépendances" },
  { "ci", "intégration continue" },
  { "chore", "maintenance" },
  { "revert", "annulation d'un commit" },
}
vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("manu_conventional_commits", { clear = true }),
  pattern = "gitcommit",
  callback = function(ev)
    map("n", "<leader>gc", function()
      vim.ui.select(cc_types, {
        prompt = "Type de commit",
        format_item = function(item)
          return ("%-9s %s"):format(item[1], item[2])
        end,
      }, function(choice)
        if not choice then
          return
        end
        local row = vim.api.nvim_win_get_cursor(0)[1]
        local line = vim.api.nvim_get_current_line()
        vim.api.nvim_set_current_line(choice[1] .. ": " .. line)
        vim.api.nvim_win_set_cursor(0, { row, #choice[1] + 2 })
        vim.cmd("startinsert!")
      end)
    end, { buffer = ev.buf, desc = "Type de commit (Conventional Commits)" })
  end,
})
