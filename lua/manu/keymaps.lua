-- Raccourcis généraux qui ne dépendent d'aucun plugin : fenêtres, buffers, onglets, édition,
-- bascules d'options, doc de la config. Retenus au tri (docs/tri.md) ; chacun est listé
-- dans KEYMAPS.md (tests/run.sh keymaps vérifie les deux).
-- Les raccourcis liés à un plugin sont déclarés dans le module de ce plugin.

local map = vim.keymap.set

-- ─── Déplacements ──────────────────────────────────────────────────────────
-- j/k suivent les lignes affichées quand il n'y a pas de compteur.
map({ "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", { desc = "Ligne suivante (affichée)", expr = true, silent = true })
map({ "n", "x" }, "<Down>", "v:count == 0 ? 'gj' : 'j'", { desc = "Ligne suivante (affichée)", expr = true, silent = true })
map({ "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'", { desc = "Ligne précédente (affichée)", expr = true, silent = true })
map({ "n", "x" }, "<Up>", "v:count == 0 ? 'gk' : 'k'", { desc = "Ligne précédente (affichée)", expr = true, silent = true })

-- n/N cherchent toujours vers l'avant/l'arrière, et déplient le résultat.
map("n", "n", "'Nn'[v:searchforward].'zv'", { expr = true, desc = "Résultat suivant" })
map({ "x", "o" }, "n", "'Nn'[v:searchforward]", { expr = true, desc = "Résultat suivant" })
map("n", "N", "'nN'[v:searchforward].'zv'", { expr = true, desc = "Résultat précédent" })
map({ "x", "o" }, "N", "'nN'[v:searchforward]", { expr = true, desc = "Résultat précédent" })

-- ─── Fenêtres ──────────────────────────────────────────────────────────────
map("n", "<C-h>", "<C-w>h", { desc = "Fenêtre de gauche", remap = true })
map("n", "<C-j>", "<C-w>j", { desc = "Fenêtre du dessous", remap = true })
map("n", "<C-k>", "<C-w>k", { desc = "Fenêtre du dessus", remap = true })
map("n", "<C-l>", "<C-w>l", { desc = "Fenêtre de droite", remap = true })
map("n", "<C-Up>", "<cmd>resize +2<cr>", { desc = "Agrandir la hauteur" })
map("n", "<C-Down>", "<cmd>resize -2<cr>", { desc = "Réduire la hauteur" })
map("n", "<C-Left>", "<cmd>vertical resize -2<cr>", { desc = "Réduire la largeur" })
map("n", "<C-Right>", "<cmd>vertical resize +2<cr>", { desc = "Agrandir la largeur" })
map("n", "<leader>-", "<C-W>s", { desc = "Découper en dessous", remap = true })
map("n", "<leader>|", "<C-W>v", { desc = "Découper à droite", remap = true })
map("n", "<leader>wd", "<C-W>c", { desc = "Fermer la fenêtre", remap = true })

-- ─── Buffers ───────────────────────────────────────────────────────────────

--- Ferme un buffer sans fermer ses fenêtres (elles passent au buffer alterné ou précédent).
local function bufdelete(buf)
  buf = (buf == nil or buf == 0) and vim.api.nvim_get_current_buf() or buf
  if vim.bo[buf].modified then
    local choice = vim.fn.confirm(
      ("Enregistrer les modifications de %q ?"):format(vim.fn.bufname(buf)),
      "&Oui\n&Non\n&Annuler"
    )
    if choice == 0 or choice == 3 then
      return
    elseif choice == 1 then
      vim.api.nvim_buf_call(buf, function()
        vim.cmd("write")
      end)
    end
  end
  for _, win in ipairs(vim.fn.win_findbuf(buf)) do
    vim.api.nvim_win_call(win, function()
      local alt = vim.fn.bufnr("#")
      if alt ~= buf and alt > 0 and vim.fn.buflisted(alt) == 1 then
        vim.api.nvim_win_set_buf(win, alt)
      else
        pcall(vim.cmd, "bprevious")
      end
      if vim.api.nvim_win_get_buf(win) == buf then
        vim.api.nvim_win_set_buf(win, vim.api.nvim_create_buf(true, false))
      end
    end)
  end
  if vim.api.nvim_buf_is_valid(buf) then
    pcall(vim.cmd, "bdelete! " .. buf)
  end
end

local function bufdelete_where(pred)
  for _, b in ipairs(vim.api.nvim_list_bufs()) do
    if vim.bo[b].buflisted and pred(b) then
      bufdelete(b)
    end
  end
end

map("n", "<leader>bb", "<cmd>e #<cr>", { desc = "Buffer précédent (alterné)" })
map("n", "<leader>`", "<cmd>e #<cr>", { desc = "Buffer précédent (alterné)" })
map("n", "<leader>bd", function()
  bufdelete(0)
end, { desc = "Fermer le buffer" })
map("n", "<leader>bo", function()
  local cur = vim.api.nvim_get_current_buf()
  bufdelete_where(function(b)
    return b ~= cur
  end)
end, { desc = "Fermer les autres buffers" })
map("n", "<leader>bi", function()
  bufdelete_where(function(b)
    return #vim.fn.win_findbuf(b) == 0
  end)
end, { desc = "Fermer les buffers invisibles" })
map("n", "<leader>bD", "<cmd>bd<cr>", { desc = "Fermer le buffer et la fenêtre" })

-- ─── Onglets ───────────────────────────────────────────────────────────────
map("n", "<leader><tab>l", "<cmd>tablast<cr>", { desc = "Dernier onglet" })
map("n", "<leader><tab>o", "<cmd>tabonly<cr>", { desc = "Fermer les autres onglets" })
map("n", "<leader><tab>f", "<cmd>tabfirst<cr>", { desc = "Premier onglet" })
map("n", "<leader><tab><tab>", "<cmd>tabnew<cr>", { desc = "Nouvel onglet" })
map("n", "<leader><tab>]", "<cmd>tabnext<cr>", { desc = "Onglet suivant" })
map("n", "<leader><tab>d", "<cmd>tabclose<cr>", { desc = "Fermer l'onglet" })
map("n", "<leader><tab>[", "<cmd>tabprevious<cr>", { desc = "Onglet précédent" })

-- ─── Édition ───────────────────────────────────────────────────────────────
-- Échap efface aussi la recherche surlignée et quitte un snippet en cours.
map({ "i", "n", "s" }, "<esc>", function()
  vim.cmd("noh")
  if vim.snippet.active() then
    vim.snippet.stop()
  end
  return "<esc>"
end, { expr = true, desc = "Échap et effacer la recherche" })

map({ "i", "x", "n", "s" }, "<C-s>", "<cmd>w<cr><esc>", { desc = "Enregistrer" })

map("n", "<A-j>", "<cmd>execute 'move .+' . v:count1<cr>==", { desc = "Descendre la ligne" })
map("n", "<A-k>", "<cmd>execute 'move .-' . (v:count1 + 1)<cr>==", { desc = "Monter la ligne" })
map("i", "<A-j>", "<esc><cmd>m .+1<cr>==gi", { desc = "Descendre la ligne" })
map("i", "<A-k>", "<esc><cmd>m .-2<cr>==gi", { desc = "Monter la ligne" })
map("x", "<A-j>", ":<C-u>execute \"'<,'>move '>+\" . v:count1<cr>gv=gv", { desc = "Descendre la sélection" })
map("x", "<A-k>", ":<C-u>execute \"'<,'>move '<-\" . (v:count1 + 1)<cr>gv=gv", { desc = "Monter la sélection" })

-- Points d'annulation intermédiaires pendant la frappe.
map("i", ",", ",<c-g>u", { desc = "Virgule + point d'annulation" })
map("i", ".", ".<c-g>u", { desc = "Point + point d'annulation" })
map("i", ";", ";<c-g>u", { desc = "Point-virgule + point d'annulation" })

-- Indenter sans perdre la sélection.
map("x", "<", "<gv", { desc = "Désindenter (garder la sélection)" })
map("x", ">", ">gv", { desc = "Indenter (garder la sélection)" })

map("n", "gco", "o<esc>Vcx<esc><cmd>normal gcc<cr>fxa<bs>", { desc = "Commentaire en dessous" })
map("n", "gcO", "O<esc>Vcx<esc><cmd>normal gcc<cr>fxa<bs>", { desc = "Commentaire au-dessus" })

-- Perso : coller sur la sélection sans écraser le registre.
map("x", "p", '"_dp', { desc = "Coller sans copier la sélection" })
map("n", "<CR>", "o<ESC>", { desc = "Ligne vide en dessous" })
map("n", "<S-CR>", "O<ESC>", { desc = "Ligne vide au-dessus" })
map("n", "<C-a>", "gg<S-v>G", { desc = "Tout sélectionner" })

-- Orthographe : touches natives, déclarées pour leur description dans which-key.
map("n", "]s", "]s", { desc = "Faute suivante" })
map("n", "[s", "[s", { desc = "Faute précédente" })
map("n", "z=", "z=", { desc = "Suggestions d'orthographe" })
map("n", "zg", "zg", { desc = "Ajouter le mot au dictionnaire" })
map("n", "zw", "zw", { desc = "Marquer le mot comme faux" })
map("n", "zug", "zug", { desc = "Retirer le mot du dictionnaire" })

-- ─── Fichiers ──────────────────────────────────────────────────────────────
map("n", "<leader>fn", function()
  vim.ui.input({ prompt = "Nouveau fichier : " }, function(input)
    if input and input ~= "" then
      vim.cmd.edit(vim.fn.fnameescape(input))
    end
  end)
end, { desc = "Nouveau fichier" })

local function copy_path(mod)
  local p = vim.fn.expand("%:" .. mod)
  if p == "" then
    vim.notify("Aucun fichier", vim.log.levels.WARN)
    return
  end
  vim.fn.setreg("+", p)
  vim.notify("Copié : " .. p)
end
map("n", "<leader>yn", function()
  copy_path("t")
end, { desc = "Copier le nom du fichier" })
map("n", "<leader>yp", function()
  copy_path(".")
end, { desc = "Copier le chemin relatif" })
map("n", "<leader>yP", function()
  copy_path("p")
end, { desc = "Copier le chemin absolu" })

map("n", "<leader>qq", "<cmd>qa<cr>", { desc = "Tout quitter" })

-- ─── Bascules (ui) ─────────────────────────────────────────────────────────

local function notify_toggle(name, on)
  vim.notify((on and "Activé : " or "Désactivé : ") .. name)
end

--- Bascule une option de fenêtre/buffer entre deux valeurs.
local function toggle_option(option, name, off, on)
  return function()
    local cur = vim.opt_local[option]:get()
    local enable = cur == off
    vim.opt_local[option] = enable and on or off
    notify_toggle(name, enable)
  end
end

map("n", "<leader>us", toggle_option("spell", "orthographe", false, true), { desc = "Basculer l'orthographe" })
map("n", "<leader>uw", toggle_option("wrap", "retour à la ligne", false, true), { desc = "Basculer le retour à la ligne" })
map("n", "<leader>uL", toggle_option("relativenumber", "numéros relatifs", false, true), { desc = "Basculer les numéros relatifs" })
map("n", "<leader>ul", function()
  local on = not vim.wo.number
  vim.wo.number, vim.wo.relativenumber = on, on
  notify_toggle("numéros de ligne", on)
end, { desc = "Basculer les numéros de ligne" })
map("n", "<leader>uc", function()
  local on = vim.wo.conceallevel == 0
  vim.wo.conceallevel = on and 2 or 0
  notify_toggle("masquage (conceal)", on)
end, { desc = "Basculer le masquage (conceal)" })
map("n", "<leader>uA", function()
  local on = vim.o.showtabline == 0
  vim.o.showtabline = on and 2 or 0
  notify_toggle("barre d'onglets", on)
end, { desc = "Basculer la barre d'onglets" })
map("n", "<leader>ud", function()
  local on = not vim.diagnostic.is_enabled()
  vim.diagnostic.enable(on)
  notify_toggle("diagnostics", on)
end, { desc = "Basculer les diagnostics" })
map("n", "<leader>uT", function()
  local on = vim.b.ts_highlight == nil
  if on then
    pcall(vim.treesitter.start)
  else
    vim.treesitter.stop()
  end
  notify_toggle("coloration Treesitter", on)
end, { desc = "Basculer la coloration Treesitter" })
map("n", "<leader>ub", function()
  vim.o.background = vim.o.background == "dark" and "light" or "dark"
  notify_toggle("fond sombre", vim.o.background == "dark")
end, { desc = "Basculer fond sombre/clair" })
map("n", "<leader>ur", "<Cmd>nohlsearch<Bar>diffupdate<Bar>normal! <C-L><CR>", { desc = "Redessiner / effacer la recherche" })
map("n", "<leader>uI", function()
  vim.treesitter.inspect_tree()
  vim.api.nvim_input("I")
end, { desc = "Arbre Treesitter" })

-- ─── Doc de la config ──────────────────────────────────────────────────────

--- Affiche un fichier Markdown de la config dans une fenêtre flottante (q ou Échap ferme).
local function show_doc(file, title)
  local path = vim.fn.stdpath("config") .. "/" .. file
  if vim.fn.filereadable(path) == 0 then
    vim.notify("Introuvable : " .. path, vim.log.levels.WARN)
    return
  end
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.fn.readfile(path))
  vim.bo[buf].filetype = "markdown"
  vim.bo[buf].readonly = true
  vim.bo[buf].modifiable = false
  vim.bo[buf].bufhidden = "wipe"
  local width = math.floor(vim.o.columns * 0.85)
  local height = math.floor(vim.o.lines * 0.85)
  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = width,
    height = height,
    row = math.floor((vim.o.lines - height) / 2),
    col = math.floor((vim.o.columns - width) / 2),
    style = "minimal",
    title = title,
    title_pos = "center",
  })
  vim.wo[win].wrap = false
  vim.wo[win].cursorline = true
  vim.wo[win].conceallevel = 2
  for _, key in ipairs({ "q", "<Esc>" }) do
    vim.keymap.set("n", key, "<cmd>close<cr>", { buffer = buf, silent = true, desc = "Fermer" })
  end
end

map("n", "<leader>K", function()
  show_doc("KEYMAPS.md", " ⌨  Raccourcis clavier ")
end, { desc = "Raccourcis (KEYMAPS.md)" })
map("n", "<leader>M", function()
  show_doc("MANUEL.md", " 📘 Manuel ")
end, { desc = "Manuel (Neovim)" })
map("n", "<leader>H", function()
  local path = vim.fn.stdpath("config") .. "/MANUEL.md"
  vim.system({ "mdview", path }, { text = true }, function(res)
    if res.code ~= 0 then
      vim.schedule(function()
        vim.notify("mdview : " .. vim.trim(res.stderr ~= "" and res.stderr or res.stdout), vim.log.levels.ERROR)
      end)
    end
  end)
end, { desc = "Manuel (navigateur)" })
