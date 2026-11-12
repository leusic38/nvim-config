-- Sélecteur unique : fzf-lua (fichiers, grep, buffers, aide, LSP, git…).
-- Remplace aussi vim.ui.select (choix dans une liste : actions de code, worktrees…).
-- Options reprises de l'ancienne config (lua/plugins/fzf.lua) ; touches de l'extra fzf de LazyVim.

vim.pack.add({ "https://github.com/ibhagwan/fzf-lua" }, { confirm = false })

local fzf = require("fzf-lua")
local root = require("manu.root")

fzf.setup({
  fzf_opts = { ["--ignore-case"] = "" },
  defaults = { formatter = "path.filename_first" },
  winopts = { border = "rounded", preview = { border = "rounded" } },
  files = {
    fd_opts = [[--color=never --type f --type l --hidden --no-ignore --exclude .git --exclude .jj --exclude node_modules --exclude vendor --exclude dist --exclude .next --exclude build --exclude cache --exclude .claude]],
  },
})
fzf.register_ui_select()

local map = vim.keymap.set

--- Appelle fzf-lua.<cmd>(opts) ; opts.cwd = "root" → racine du projet.
local function pick(cmd, opts)
  return function()
    opts = vim.deepcopy(opts or {})
    if opts.cwd == "root" then
      opts.cwd = root()
    end
    fzf[cmd](opts)
  end
end

-- Fichiers
map("n", "<leader><space>", pick("files", { cwd = "root" }), { desc = "Fichiers (racine du projet)" })
map("n", "<leader>ff", pick("files", { cwd = "root" }), { desc = "Fichiers (racine du projet)" })
map("n", "<leader>fF", pick("files"), { desc = "Fichiers (dossier courant)" })
map("n", "<leader>fg", pick("git_files"), { desc = "Fichiers suivis par git" })
map("n", "<leader>fr", pick("oldfiles"), { desc = "Fichiers récents" })
map("n", "<leader>fR", pick("oldfiles", { cwd_only = true }), { desc = "Fichiers récents (dossier courant)" })
map("n", "<leader>fc", pick("files", { cwd = vim.fn.stdpath("config") }), { desc = "Fichiers de la config Neovim" })

-- Buffers
map("n", "<leader>,", pick("buffers", { sort_mru = true, sort_lastused = true }), { desc = "Changer de buffer" })
map("n", "<leader>fb", pick("buffers", { sort_mru = true, sort_lastused = true }), { desc = "Buffers" })
map("n", "<leader>fB", pick("buffers", { show_unlisted = true }), { desc = "Buffers (tous)" })

-- Recherche
map("n", "<leader>/", pick("live_grep", { cwd = "root" }), { desc = "Grep (racine du projet)" })
map("n", "<leader>sg", pick("live_grep", { cwd = "root" }), { desc = "Grep (racine du projet)" })
map("n", "<leader>sG", pick("live_grep"), { desc = "Grep (dossier courant)" })
map("n", "<leader>sw", pick("grep_cword", { cwd = "root" }), { desc = "Mot sous le curseur (racine)" })
map("x", "<leader>sw", pick("grep_visual", { cwd = "root" }), { desc = "Sélection (racine)" })
map("n", "<leader>sW", pick("grep_cword"), { desc = "Mot sous le curseur (dossier courant)" })
map("x", "<leader>sW", pick("grep_visual"), { desc = "Sélection (dossier courant)" })
map("n", "<leader>sb", pick("blines"), { desc = "Lignes du buffer" })
map("n", "<leader>:", pick("command_history"), { desc = "Historique des commandes" })
map("n", "<leader>sc", pick("command_history"), { desc = "Historique des commandes" })
map("n", "<leader>s/", pick("search_history"), { desc = "Historique des recherches" })
map("n", '<leader>s"', pick("registers"), { desc = "Registres" })
map("n", "<leader>sC", pick("commands"), { desc = "Commandes" })
map("n", "<leader>sa", pick("autocmds"), { desc = "Autocommandes" })
map("n", "<leader>sh", pick("helptags"), { desc = "Pages d'aide" })
map("n", "<leader>sH", pick("highlights"), { desc = "Groupes de surlignage" })
map("n", "<leader>sM", pick("manpages"), { desc = "Pages man" })
map("n", "<leader>sk", pick("keymaps"), { desc = "Raccourcis" })
map("n", "<leader>sj", pick("jumps"), { desc = "Liste des sauts" })
map("n", "<leader>sm", pick("marks"), { desc = "Marques" })
map("n", "<leader>sl", pick("loclist"), { desc = "Liste locale" })
map("n", "<leader>sq", pick("quickfix"), { desc = "Quickfix" })
map("n", "<leader>sR", pick("resume"), { desc = "Reprendre la dernière recherche" })
map("n", "<leader>sd", pick("diagnostics_workspace"), { desc = "Diagnostics (projet)" })
map("n", "<leader>sD", pick("diagnostics_document"), { desc = "Diagnostics (buffer)" })
map("n", "<leader>ss", pick("lsp_document_symbols"), { desc = "Symboles du fichier (LSP)" })
map("n", "<leader>sS", pick("lsp_live_workspace_symbols"), { desc = "Symboles du projet (LSP)" })
map("n", "<leader>uC", pick("colorschemes"), { desc = "Thèmes (aperçu)" })
