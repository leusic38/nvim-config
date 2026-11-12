-- Page d'accueil, sans plugin.
--
-- S'affiche au démarrage quand on lance :
--   nn                      → dans le dossier courant ;
--   nn ~/Projects/lama/     → Neovim se place dans ce dossier (:cd), puis l'accueil
--                             s'affiche à la place d'Oil.
-- Pas d'accueil si on ouvre un fichier, plusieurs arguments, ou du texte sur l'entrée
-- standard (nn -). :Accueil la rouvre à tout moment.

local M = {}

local ns = vim.api.nvim_create_namespace("manu_dashboard")
local FT = "manu-dashboard"

-- ─── Contenu ───────────────────────────────────────────────────────────────

local HEADER = {
  "┏┓╻┏━╸┏━┓╻ ╻╻┏┳┓┏━┓┏┓╻╻ ╻",
  "┃┗┫┣╸ ┃ ┃┃┏┛┃┃┃┃┣━┫┃┗┫┃ ┃",
  "╹ ╹┗━╸┗━┛┗┛ ╹╹ ╹╹ ╹╹ ╹┗━┛",
}

local function cwd()
  return vim.uv.cwd() or vim.fn.getcwd()
end

local function feed(keys)
  return function()
    vim.api.nvim_feedkeys(vim.keycode(keys), "m", false)
  end
end

--- Actions : touche, libellé, raccourci équivalent hors accueil, fonction.
local ACTIONS = {
  { "f", "Trouver un fichier", "<leader><space>", function()
    require("fzf-lua").files({ cwd = cwd() })
  end },
  { "r", "Fichiers récents du projet", "<leader>fR", function()
    require("fzf-lua").oldfiles({ cwd_only = true })
  end },
  { "g", "Chercher du texte", "<leader>/", function()
    require("fzf-lua").live_grep({ cwd = cwd() })
  end },
  { "s", "Restaurer la session", "<leader>qs", function()
    require("persistence").load()
  end },
  { "e", "Explorer le dossier (Oil)", "-", function()
    require("oil").open(cwd())
  end },
  { "n", "Nouveau fichier", ":enew", function()
    vim.cmd.enew()
  end },
  { "G", "Lazygit", "<leader>gg", function()
    require("manu.terminal").float_cmd("lazygit", { cwd = cwd() })
  end },
  { "a", "Claude (sidekick)", "<leader>as", feed("<leader>as") },
  { "c", "Config Neovim", "<leader>fc", function()
    require("fzf-lua").files({ cwd = vim.fn.stdpath("config") })
  end },
  { "m", "Manuel", "<leader>M", feed("<leader>M") },
  { "q", "Quitter", "<leader>qq", function()
    vim.cmd("qa")
  end },
}

--- Fichiers récents situés sous le dossier courant (5 au plus).
local function recent_files()
  local root = vim.fs.normalize(cwd()) .. "/"
  local out = {}
  for _, f in ipairs(vim.v.oldfiles) do
    f = vim.fs.normalize(f)
    if f:sub(1, #root) == root and vim.fn.filereadable(f) == 1 then
      table.insert(out, f)
      if #out == 5 then
        break
      end
    end
  end
  return out
end

local function git_branch()
  local res = vim.system({ "git", "branch", "--show-current" }, { cwd = cwd(), text = true }):wait(500)
  return res and res.code == 0 and vim.trim(res.stdout or "") or nil
end

-- ─── Rendu ─────────────────────────────────────────────────────────────────

--- Lignes et surlignages ; items[ligne] = action, pour <CR>.
local function build(width)
  local lines, hls, items = {}, {}, {}
  local function center(text)
    local pad = math.max(0, math.floor((width - vim.fn.strdisplaywidth(text)) / 2))
    return string.rep(" ", pad) .. text, pad
  end
  local function add(text, group)
    local line, pad = center(text)
    table.insert(lines, line)
    if group then
      table.insert(hls, { #lines - 1, pad, #line, group })
    end
    return #lines, pad
  end

  for _, l in ipairs(HEADER) do
    add(l, "Title")
  end
  add("")
  local branch = git_branch()
  add(vim.fn.fnamemodify(cwd(), ":~") .. (branch and branch ~= "" and ("  " .. branch) or ""), "Directory")
  add("")

  -- Actions sur une colonne de largeur fixe, centrée.
  local col_w = 44
  local left = math.max(0, math.floor((width - col_w) / 2))
  local function item(key, label, hint, fn)
    local text = ("%s  %-26s %s"):format(key, label, hint)
    local line = string.rep(" ", left) .. text
    table.insert(lines, line)
    local row = #lines - 1
    table.insert(hls, { row, left, left + #key, "Special" })
    table.insert(hls, { row, left + #key + 2 + 27, #line, "Comment" })
    items[#lines] = { key = key, fn = fn, col = left }
  end

  for _, a in ipairs(ACTIONS) do
    item(a[1], a[2], a[3], a[4])
  end

  local recents = recent_files()
  if #recents > 0 then
    add("")
    add("Récents dans ce dossier", "Comment")
    for i, f in ipairs(recents) do
      local rel = vim.fn.fnamemodify(f, ":.")
      if #rel > 40 then
        rel = "…" .. rel:sub(-39)
      end
      item(tostring(i), rel, "", function()
        vim.cmd.edit(vim.fn.fnameescape(f))
      end)
    end
  end

  add("")
  local v = vim.version()
  add(("Neovim %d.%d.%d · %d plugins · :Accueil pour revenir ici"):format(
    v.major,
    v.minor,
    v.patch,
    #vim.pack.get(nil, { info = false })
  ), "Comment")
  return lines, hls, items
end

local function render(buf, win)
  local width = vim.api.nvim_win_get_width(win)
  local lines, hls, items = build(width)
  -- Centrage vertical.
  local top = math.max(0, math.floor((vim.api.nvim_win_get_height(win) - #lines) / 2))
  local padded = {}
  for _ = 1, top do
    table.insert(padded, "")
  end
  vim.list_extend(padded, lines)

  vim.bo[buf].modifiable = true
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, padded)
  vim.bo[buf].modifiable = false
  vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
  for _, h in ipairs(hls) do
    vim.api.nvim_buf_set_extmark(buf, ns, h[1] + top, h[2], { end_col = h[3], hl_group = h[4] })
  end

  local by_row = {}
  local first
  for row, it in pairs(items) do
    by_row[row + top] = it
    first = (not first or row + top < first) and row + top or first
  end
  M._items = by_row
  if first and vim.api.nvim_win_get_buf(win) == buf then
    vim.api.nvim_win_set_cursor(win, { first, by_row[first].col })
  end
  return by_row
end

-- ─── Ouverture ─────────────────────────────────────────────────────────────

--- Ouvre la page d'accueil dans la fenêtre courante.
function M.open()
  local buf = vim.api.nvim_create_buf(false, true)
  vim.bo[buf].filetype = FT
  vim.bo[buf].bufhidden = "wipe"
  vim.bo[buf].buftype = "nofile"
  vim.bo[buf].swapfile = false
  local win = vim.api.nvim_get_current_win()
  vim.api.nvim_win_set_buf(win, buf)
  for opt, val in pairs({
    number = false,
    relativenumber = false,
    cursorline = false,
    signcolumn = "no",
    foldcolumn = "0",
    list = false,
    spell = false,
    wrap = false,
    colorcolumn = "",
  }) do
    vim.wo[win][0][opt] = val
  end

  local items = render(buf, win)
  local function bmap(lhs, fn, desc)
    vim.keymap.set("n", lhs, fn, { buffer = buf, nowait = true, silent = true, desc = desc })
  end
  for _, it in pairs(items) do
    bmap(it.key, it.fn, "Accueil : " .. it.key)
  end
  bmap("<CR>", function()
    local it = M._items[vim.api.nvim_win_get_cursor(0)[1]]
    if it then
      it.fn()
    end
  end, "Accueil : ouvrir l'élément sous le curseur")

  local group = vim.api.nvim_create_augroup("manu_dashboard_buf", { clear = true })
  vim.api.nvim_create_autocmd({ "VimResized", "WinResized" }, {
    group = group,
    buffer = buf,
    callback = function()
      local w = vim.fn.bufwinid(buf)
      if w ~= -1 then
        items = render(buf, w)
      end
    end,
  })
  return buf
end

--- Au démarrage : faut-il afficher l'accueil ? Renvoie (oui, dossier_argument|nil).
local function startup_target()
  local argc = vim.fn.argc()
  if argc > 1 then
    return false
  end
  if argc == 1 then
    -- Oil a déjà remplacé un dossier en argument par « oil:///chemin/ ».
    local arg = vim.fn.argv(0):gsub("^oil://", "")
    if vim.fn.isdirectory(arg) == 1 then
      return true, vim.fn.fnamemodify(arg, ":p")
    end
    return false
  end
  -- Sans argument : seulement si le buffer de départ est vide (pas de « nn - »).
  local buf = vim.api.nvim_get_current_buf()
  local lines = vim.api.nvim_buf_get_lines(buf, 0, 2, false)
  return vim.api.nvim_buf_get_name(buf) == ""
    and not vim.bo[buf].modified
    and #lines <= 1
    and (lines[1] or "") == ""
end

vim.api.nvim_create_autocmd("VimEnter", {
  group = vim.api.nvim_create_augroup("manu_dashboard", { clear = true }),
  once = true,
  callback = function()
    local show, dir = startup_target()
    if not show then
      return
    end
    local start_buf = vim.api.nvim_get_current_buf()
    if dir then
      vim.cmd.cd(vim.fn.fnameescape(dir))
      vim.cmd("silent! argdelete *")
    end
    M.open()
    -- Le buffer de départ (vide, ou le dossier ouvert par Oil) n'a plus d'usage.
    for _, b in ipairs(vim.api.nvim_list_bufs()) do
      local name = vim.api.nvim_buf_get_name(b)
      local is_dir = name ~= "" and (vim.fn.isdirectory(name) == 1 or name:match("^oil://"))
      if (b == start_buf or is_dir) and vim.bo[b].filetype ~= FT then
        pcall(vim.api.nvim_buf_delete, b, { force = true })
      end
    end
  end,
})

vim.api.nvim_create_user_command("Accueil", function()
  M.open()
end, { desc = "Ouvrir la page d'accueil" })

return M
