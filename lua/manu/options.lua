-- Options générales et leader. Valeurs reprises de LazyVim (lua/lazyvim/config/options.lua),
-- sans ce qui dépend de LazyVim (statuscolumn, formatexpr, vim.g.lazyvim_*), plus nos choix :
-- bordures arrondies, orthographe en/fr désactivée par défaut, diagnostics en fin de ligne.

vim.g.mapleader = " "
vim.g.maplocalleader = "\\"
vim.g.markdown_recommended_style = 0

local opt = vim.opt

opt.autowrite = true
opt.clipboard = vim.env.SSH_CONNECTION and "" or "unnamedplus"
opt.completeopt = "menu,menuone,noselect"
opt.conceallevel = 2
opt.confirm = true
opt.cursorline = true
opt.expandtab = true
opt.fillchars = { foldopen = "\u{f47c}", foldclose = "\u{f460}", fold = " ", foldsep = " ", diff = "╱", eob = " " }
opt.foldlevel = 99
opt.foldmethod = "expr"
opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
opt.foldtext = ""
opt.formatoptions = "jcroqlnt"
opt.grepformat = "%f:%l:%c:%m"
opt.grepprg = "rg --vimgrep"
opt.ignorecase = true
opt.inccommand = "nosplit"
opt.jumpoptions = "view"
opt.laststatus = 3
opt.linebreak = true
opt.list = true
opt.mouse = "a"
opt.number = true
opt.pumblend = 10
opt.pumheight = 10
opt.relativenumber = true
opt.ruler = false
opt.scrolloff = 4
opt.sessionoptions = { "buffers", "curdir", "tabpages", "winsize", "help", "globals", "skiprtp", "folds" }
opt.shiftround = true
opt.shiftwidth = 2
opt.shortmess:append({ W = true, I = true, c = true, C = true })
opt.showmode = false
opt.sidescrolloff = 8
opt.signcolumn = "yes"
opt.smartcase = true
opt.smartindent = true
opt.smoothscroll = true
opt.spell = false -- activer avec <leader>us
opt.spelllang = { "en", "fr" }
-- Dictionnaire français absent : le télécharger sans question (sinon une invite bloque à la
-- première ouverture d'un Markdown ou d'un message de commit, et en headless pour toujours).
require("nvim.spellfile").config({ confirm = false })
opt.splitbelow = true
opt.splitkeep = "screen"
opt.splitright = true
opt.tabstop = 2
opt.termguicolors = true
opt.timeoutlen = 300
opt.undofile = true
opt.undolevels = 10000
opt.updatetime = 200
opt.virtualedit = "block"
opt.wildmode = "longest:full,full"
opt.winborder = "rounded"
opt.winminwidth = 5
opt.wrap = false

vim.diagnostic.config({
  virtual_text = { spacing = 4, prefix = "●" },
  virtual_lines = false,
  severity_sort = true,
  float = { border = "rounded" },
})
