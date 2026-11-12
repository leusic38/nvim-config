-- Terminal : toggleterm.nvim (terminal flottant/horizontal/vertical qui se cache et revient).
-- Config reprise de l'ancienne lua/plugins/terminal.lua ; lazygit et lazydocker y tournent
-- en plein écran flottant (remplace Snacks.terminal / Snacks.lazygit).

vim.pack.add({ { src = "https://github.com/akinsho/toggleterm.nvim", version = vim.version.range("2.*") } }, {
  confirm = false,
})

local M = {}

M.root = require("manu.root")

require("toggleterm").setup({
  size = function(term)
    if term.direction == "horizontal" then
      return 15
    elseif term.direction == "vertical" then
      return math.floor(vim.o.columns * 0.4)
    end
    return 20
  end,
  direction = "float",
  float_opts = {
    border = "rounded",
    width = function()
      return math.floor(vim.o.columns * 0.8)
    end,
    height = function()
      return math.floor(vim.o.lines * 0.8)
    end,
    winblend = 0,
  },
  persist_mode = true,
  persist_size = true,
  start_in_insert = true,
  shade_terminals = true,
  on_open = function(term)
    vim.cmd("startinsert!")
    local function tmap(lhs, rhs, desc)
      vim.keymap.set("t", lhs, rhs, { buffer = term.bufnr, silent = true, desc = desc })
    end
    tmap("<Esc>", "<C-\\><C-n><cmd>close<cr>", "Fermer le terminal")
    tmap("<C-Space>", "<C-\\><C-n>", "Mode normal (sans fermer)")
    tmap("<C-h>", "<C-\\><C-n><C-w>h", "Fenêtre de gauche")
    tmap("<C-j>", "<C-\\><C-n><C-w>j", "Fenêtre du dessous")
    tmap("<C-k>", "<C-\\><C-n><C-w>k", "Fenêtre du dessus")
    tmap("<C-l>", "<C-\\><C-n><C-w>l", "Fenêtre de droite")
  end,
})

local Terminal = require("toggleterm.terminal").Terminal

--- Lance `cmd` dans un terminal flottant (90 %, bordure arrondie) qui se ferme à sa sortie.
--- Les touches (dont <Esc>) vont au programme. Erreur si `cmd` n'est pas exécutable.
---@param cmd string
---@param opts? { cwd?: string }
function M.float_cmd(cmd, opts)
  opts = opts or {}
  local exe = vim.split(cmd, " ", { trimempty = true })[1]
  if vim.fn.executable(exe) == 0 then
    vim.notify(exe .. " introuvable dans le PATH", vim.log.levels.ERROR)
    return
  end
  local term = Terminal:new({
    cmd = cmd,
    dir = opts.cwd or M.root(),
    direction = "float",
    hidden = true,
    close_on_exit = true,
    float_opts = {
      border = "rounded",
      width = math.floor(vim.o.columns * 0.9),
      height = math.floor(vim.o.lines * 0.9),
    },
    on_open = function()
      vim.cmd("startinsert!")
    end,
  })
  term:open()
  return term
end

-- Terminaux shell par dossier : <leader>ft (racine du projet), <leader>fT (dossier courant).
local by_dir = {}
local function toggle_in(dir)
  if not by_dir[dir] then
    by_dir[dir] = Terminal:new({ dir = dir, direction = "float", hidden = true })
  end
  by_dir[dir]:toggle()
end

local map = vim.keymap.set
map({ "n", "t" }, "<C-\\>", "<cmd>ToggleTerm direction=float<cr>", { desc = "Terminal flottant" })
map("n", "<leader>tf", "<cmd>ToggleTerm direction=float<cr>", { desc = "Terminal flottant" })
map("n", "<leader>th", "<cmd>ToggleTerm direction=horizontal<cr>", { desc = "Terminal horizontal" })
map("n", "<leader>tv", "<cmd>ToggleTerm direction=vertical<cr>", { desc = "Terminal vertical" })
map("n", "<leader>ft", function()
  toggle_in(M.root())
end, { desc = "Terminal (racine du projet)" })
map("n", "<leader>fT", function()
  toggle_in(vim.uv.cwd())
end, { desc = "Terminal (dossier courant)" })
-- <C-/> : certains terminaux envoient <C-_> pour la même touche.
for _, lhs in ipairs({ "<C-/>", "<C-_>" }) do
  map({ "n", "t" }, lhs, function()
    toggle_in(M.root())
  end, { desc = "Terminal (racine du projet)" })
end

map("n", "<leader>gg", function()
  M.float_cmd("lazygit", { cwd = M.root() })
end, { desc = "Lazygit (racine du projet)" })
map("n", "<leader>gG", function()
  M.float_cmd("lazygit", { cwd = vim.uv.cwd() })
end, { desc = "Lazygit (dossier courant)" })
-- Lazydocker à la racine du projet : il y retrouve le docker-compose.
map("n", "<leader>od", function()
  M.float_cmd("lazydocker", { cwd = M.root() })
end, { desc = "Lazydocker (conteneurs)" })

return M
