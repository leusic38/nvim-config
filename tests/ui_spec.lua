-- Interface : thème selon ~/.config/theme-mode, plugins d'interface chargés, lockfile.
local t = require("helpers")
local ui = require("manu.ui")

t.ok((vim.g.colors_name or ""):find("^catppuccin"), "thème catppuccin au démarrage")

local tmp = vim.fn.stdpath("config") .. "/tests/tmp"
vim.fn.mkdir(tmp, "p")
local mode_file = tmp .. "/theme-mode"
vim.g.manu_theme_mode_file = mode_file

vim.fn.writefile({ "light" }, mode_file)
ui.apply_theme()
t.eq(vim.g.colors_name, "catppuccin-latte", "light → latte")

vim.fn.writefile({ "dark" }, mode_file)
ui.apply_theme()
t.eq(vim.g.colors_name, "catppuccin-mocha", "dark → mocha")

vim.fn.delete(mode_file)
local ok = pcall(ui.apply_theme)
t.ok(ok, "fichier absent : pas d'erreur")
t.eq(vim.g.colors_name, "catppuccin-mocha", "fichier absent → mocha")

for _, mod in ipairs({ "lualine", "bufferline", "which-key", "nvim-web-devicons" }) do
  t.ok(package.loaded[mod] ~= nil, mod .. " chargé")
end
t.eq(vim.o.showtabline, 2, "bufferline toujours visible")
t.eq(vim.fn.filereadable(vim.fn.stdpath("config") .. "/nvim-pack-lock.json"), 1, "lockfile présent")

local names = {}
for _, p in ipairs(vim.pack.get(nil, { info = false })) do
  names[p.spec.name] = true
end
for _, banned in ipairs({ "noice.nvim", "snacks.nvim", "neo-tree.nvim", "telescope.nvim", "dashboard-nvim" }) do
  t.ok(not names[banned], banned .. " absent")
end

t.finish()
