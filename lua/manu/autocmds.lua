-- Autocmds généraux, repris de LazyVim (lua/lazyvim/config/autocmds.lua) avec le préfixe manu_,
-- plus le forçage de l'indentation YAML de l'ancienne config.

local function augroup(name)
  return vim.api.nvim_create_augroup("manu_" .. name, { clear = true })
end

-- Recharger le fichier s'il a changé sur le disque.
vim.api.nvim_create_autocmd({ "FocusGained", "TermClose", "TermLeave" }, {
  group = augroup("checktime"),
  callback = function()
    if vim.o.buftype ~= "nofile" then
      vim.cmd("checktime")
    end
  end,
})

-- Surligner le texte copié.
vim.api.nvim_create_autocmd("TextYankPost", {
  group = augroup("highlight_yank"),
  callback = function()
    vim.hl.on_yank()
  end,
})

-- Rééquilibrer les fenêtres quand le terminal change de taille.
vim.api.nvim_create_autocmd("VimResized", {
  group = augroup("resize_splits"),
  callback = function()
    local current_tab = vim.fn.tabpagenr()
    vim.cmd("tabdo wincmd =")
    vim.cmd("tabnext " .. current_tab)
  end,
})

-- Revenir à la dernière position connue dans un fichier.
vim.api.nvim_create_autocmd("BufReadPost", {
  group = augroup("last_loc"),
  callback = function(event)
    local buf = event.buf
    if vim.bo[buf].filetype == "gitcommit" or vim.b[buf].manu_last_loc then
      return
    end
    vim.b[buf].manu_last_loc = true
    local mark = vim.api.nvim_buf_get_mark(buf, '"')
    if mark[1] > 0 and mark[1] <= vim.api.nvim_buf_line_count(buf) then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- Fermer certaines fenêtres utilitaires avec q.
vim.api.nvim_create_autocmd("FileType", {
  group = augroup("close_with_q"),
  pattern = {
    "help",
    "qf",
    "man",
    "lspinfo",
    "checkhealth",
    "notify",
    "grug-far",
    "gitsigns-blame",
    "dap-float",
    "dbout",
    "neotest-output",
    "neotest-output-panel",
    "neotest-summary",
    "startuptime",
  },
  callback = function(event)
    vim.bo[event.buf].buflisted = false
    vim.schedule(function()
      if not vim.api.nvim_buf_is_valid(event.buf) then
        return
      end
      vim.keymap.set("n", "q", function()
        vim.cmd("close")
        pcall(vim.api.nvim_buf_delete, event.buf, { force = true })
      end, { buffer = event.buf, silent = true, desc = "Fermer la fenêtre" })
    end)
  end,
})

-- Pages man ouvertes dans un buffer : hors de la liste des buffers.
vim.api.nvim_create_autocmd("FileType", {
  group = augroup("man_unlisted"),
  pattern = "man",
  callback = function(event)
    vim.bo[event.buf].buflisted = false
  end,
})

-- Retour à la ligne et orthographe dans les textes.
vim.api.nvim_create_autocmd("FileType", {
  group = augroup("wrap_spell"),
  pattern = { "text", "plaintex", "typst", "gitcommit", "markdown" },
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.spell = true
  end,
})

-- JSON : ne pas masquer les guillemets.
vim.api.nvim_create_autocmd("FileType", {
  group = augroup("json_conceal"),
  pattern = { "json", "jsonc", "json5" },
  callback = function()
    vim.opt_local.conceallevel = 0
  end,
})

-- Créer les dossiers manquants à l'enregistrement.
vim.api.nvim_create_autocmd("BufWritePre", {
  group = augroup("auto_create_dir"),
  callback = function(event)
    if event.match:match("^%w%w+:[\\/][\\/]") then
      return
    end
    local file = vim.uv.fs_realpath(event.match) or event.match
    vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
  end,
})

-- ─── YAML : toujours 2 espaces ────────────────────────────────────────────────
-- L'ftplugin yaml du runtime pose déjà sw/sts=2, mais le support .editorconfig
-- intégré à Neovim s'applique *après* FileType et écrase la valeur dès qu'un
-- projet déclare indent_size = 4. Un autocmd FileType perdrait donc la course :
-- on enveloppe directement les handlers d'editorconfig pour neutraliser
-- l'indentation sur les buffers YAML uniquement (le reste du .editorconfig —
-- charset, fins de ligne, trim, max_line_length — continue de s'appliquer).
-- Le groupe manu_yaml_editorconfig ne contient pas d'autocmd : il signale ce
-- réglage dans :autocmd et les tests.
augroup("yaml_editorconfig")
local editorconfig = require("editorconfig")

local function is_yaml(bufnr)
  if vim.bo[bufnr].filetype:match("^yaml") then
    return true
  end
  return vim.api.nvim_buf_get_name(bufnr):match("%.ya?ml$") ~= nil
end

local function force_on_yaml(prop, forced)
  local original = editorconfig.properties[prop]
  editorconfig.properties[prop] = function(bufnr, val, opts)
    return original(bufnr, is_yaml(bufnr) and forced or val, opts)
  end
end

force_on_yaml("indent_size", "2")
force_on_yaml("tab_width", "2")
force_on_yaml("indent_style", "space")
