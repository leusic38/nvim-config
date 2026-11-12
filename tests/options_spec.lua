-- Options, leader, diagnostics et groupes d'autocmds du socle.
local t = require("helpers")

t.eq(vim.g.mapleader, " ", "leader = espace")
t.eq(vim.g.maplocalleader, "\\", "localleader = \\")
t.ok(vim.o.relativenumber, "relativenumber")
t.eq(vim.o.clipboard, "unnamedplus", "clipboard unnamedplus")
t.eq(vim.o.winborder, "rounded", "winborder rounded")
t.eq(vim.o.laststatus, 3, "laststatus 3")
t.ok(vim.o.undofile, "undofile")
t.eq(vim.o.timeoutlen, 300, "timeoutlen 300")
t.eq(vim.o.spell, false, "spell désactivé")
t.ok(vim.deep_equal(vim.opt.spelllang:get(), { "en", "fr" }), "spelllang en,fr")
t.eq(vim.o.showmode, false, "showmode off")
t.eq(vim.o.cmdheight, 1, "cmdheight 1")
t.eq(vim.o.foldmethod, "expr", "foldmethod expr")
t.eq(vim.o.foldexpr, "v:lua.vim.treesitter.foldexpr()", "foldexpr treesitter")

local diag = vim.diagnostic.config()
t.ok(diag.virtual_text, "diagnostics en fin de ligne")
t.ok(not diag.virtual_lines, "pas de virtual_lines")
t.ok(diag.severity_sort, "diagnostics triés par sévérité")

for _, group in ipairs({
  "manu_highlight_yank",
  "manu_last_loc",
  "manu_close_with_q",
  "manu_checktime",
  "manu_resize_splits",
  "manu_auto_create_dir",
  "manu_yaml_editorconfig",
}) do
  t.ok(pcall(vim.api.nvim_get_autocmds, { group = group }), "groupe d'autocmds " .. group)
end

-- YAML : l'indentation d'un .editorconfig est forcée à 2 espaces, pas celle des autres fichiers.
local dir = vim.fn.stdpath("config") .. "/tests/tmp/editorconfig"
vim.fn.mkdir(dir, "p")
vim.fn.writefile({ "root = true", "[*]", "indent_style = space", "indent_size = 4" }, dir .. "/.editorconfig")
vim.cmd("edit " .. dir .. "/a.yaml")
t.eq(vim.bo.shiftwidth, 2, "YAML : 2 espaces malgré indent_size = 4")
vim.cmd("edit " .. dir .. "/a.sh")
t.eq(vim.bo.shiftwidth, 4, "autres fichiers : indent_size du .editorconfig respecté")

t.finish()
