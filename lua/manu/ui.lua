-- Interface : thème, icônes, barre de statut, liste des buffers, aide aux raccourcis.
--
-- catppuccin        : thème, mocha (sombre) ou latte (clair) selon ~/.config/theme-mode.
-- nvim-web-devicons : icônes de fichiers (lualine, bufferline, fzf-lua, oil).
-- lualine.nvim      : barre de statut globale (mode, branche, diff, diagnostics, position).
-- bufferline.nvim   : buffers ouverts en onglets en haut de l'écran.
-- which-key.nvim    : affiche les suites possibles d'une touche (<leader>…) avec leur desc.

vim.pack.add({
  { src = "https://github.com/catppuccin/nvim", name = "catppuccin", version = vim.version.range("2.*") },
  "https://github.com/nvim-tree/nvim-web-devicons",
  "https://github.com/nvim-lualine/lualine.nvim",
  { src = "https://github.com/akinsho/bufferline.nvim", version = vim.version.range("4.*") },
  { src = "https://github.com/folke/which-key.nvim", version = vim.version.range("3.*") },
}, { confirm = false })

local M = {}

-- ─── Thème ─────────────────────────────────────────────────────────────────

require("catppuccin").setup({
  flavour = "auto",
  background = { light = "latte", dark = "mocha" },
  integrations = {
    blink_cmp = true,
    fzf = true,
    gitsigns = true,
    mason = true,
    which_key = true,
    native_lsp = { enabled = true },
  },
})

--- Applique catppuccin-latte si le fichier de mode (vim.g.manu_theme_mode_file,
--- défaut ~/.config/theme-mode) contient « light », sinon catppuccin-mocha.
function M.apply_theme()
  local file = vim.g.manu_theme_mode_file or vim.fn.expand("~/.config/theme-mode")
  local mode = "dark"
  local ok, lines = pcall(vim.fn.readfile, file, "", 1)
  if ok and lines[1] and vim.trim(lines[1]) == "light" then
    mode = "light"
  end
  vim.o.background = mode
  vim.cmd.colorscheme(mode == "light" and "catppuccin-latte" or "catppuccin-mocha")
end

M.apply_theme()

-- ─── Icônes, barre de statut ───────────────────────────────────────────────

require("nvim-web-devicons").setup({})

require("lualine").setup({
  options = {
    theme = "auto",
    globalstatus = true,
    disabled_filetypes = { statusline = {} },
  },
  -- Sections par défaut de lualine : mode | branche, diff, diagnostics | fichier | … | position.
})

-- ─── Liste des buffers ─────────────────────────────────────────────────────

local bufdelete = require("manu.bufdelete")

require("bufferline").setup({
  highlights = require("catppuccin.special.bufferline").get_theme(),
  options = {
    mode = "buffers",
    close_command = function(n)
      bufdelete.delete(n)
    end,
    right_mouse_command = function(n)
      bufdelete.delete(n)
    end,
    diagnostics = "nvim_lsp",
    always_show_bufferline = true,
    separator_style = "slant",
    show_tab_indicators = true,
  },
})
vim.o.showtabline = 2

local map = vim.keymap.set
map("n", "<S-h>", "<cmd>BufferLineCyclePrev<cr>", { desc = "Buffer précédent" })
map("n", "<S-l>", "<cmd>BufferLineCycleNext<cr>", { desc = "Buffer suivant" })
map("n", "[b", "<cmd>BufferLineCyclePrev<cr>", { desc = "Buffer précédent" })
map("n", "]b", "<cmd>BufferLineCycleNext<cr>", { desc = "Buffer suivant" })
map("n", "[B", "<cmd>BufferLineMovePrev<cr>", { desc = "Déplacer le buffer à gauche" })
map("n", "]B", "<cmd>BufferLineMoveNext<cr>", { desc = "Déplacer le buffer à droite" })
map("n", "<leader>bp", "<cmd>BufferLineTogglePin<cr>", { desc = "Épingler/désépingler le buffer" })
map("n", "<leader>bP", "<cmd>BufferLineGroupClose ungrouped<cr>", { desc = "Fermer les buffers non épinglés" })
map("n", "<leader>bl", "<cmd>BufferLineCloseLeft<cr>", { desc = "Fermer les buffers à gauche" })
map("n", "<leader>br", "<cmd>BufferLineCloseRight<cr>", { desc = "Fermer les buffers à droite" })
map("n", "<leader>bj", "<cmd>BufferLinePick<cr>", { desc = "Choisir un buffer" })

-- ─── which-key ─────────────────────────────────────────────────────────────

local wk = require("which-key")
wk.setup({
  preset = "helix",
  spec = {
    {
      mode = { "n", "x" },
      { "<leader><tab>", group = "onglets" },
      { "<leader>a", group = "IA (Claude)" },
      { "<leader>ae", group = "Claude expert" },
      { "<leader>R", group = "refactoring" },
      { "<leader>S", group = "Symfony" },
      { "<leader>C", group = "Composer" },
      { "<leader>p", group = "PHP" },
      { "<leader>pl", group = "PHP : format / analyse" },
      { "<leader>gh", group = "hunks" },
      { "<leader>t", group = "terminal" },
      { "<leader>b", group = "buffers" },
      { "<leader>c", group = "code" },
      { "<leader>f", group = "fichiers" },
      { "<leader>g", group = "git" },
      { "<leader>o", group = "outils" },
      { "<leader>q", group = "quitter/sessions" },
      { "<leader>s", group = "recherche" },
      { "<leader>u", group = "interface" },
      { "<leader>w", group = "fenêtres", proxy = "<c-w>" },
      { "<leader>x", group = "diagnostics/quickfix" },
      { "<leader>y", group = "copier" },
      { "[", group = "précédent" },
      { "]", group = "suivant" },
      { "g", group = "aller à" },
      { "z", group = "plis/orthographe" },
    },
  },
})

map("n", "<leader>?", function()
  wk.show({ global = false })
end, { desc = "Raccourcis du buffer (which-key)" })
map("n", "<c-w><space>", function()
  wk.show({ keys = "<c-w>", loop = true })
end, { desc = "Mode fenêtres (which-key)" })

return M
