-- Édition et IA : plugins retenus au tri présents et actifs, écartés absents ; sidekick,
-- worktrees sans Snacks, raccourcis IA.
local t = require("helpers")

local plugins = {}
for _, p in ipairs(vim.pack.get(nil, { info = false })) do
  plugins[p.spec.name] = p.active
end

-- Domaine « édition » du tri : retenus / écartés.
local kept = {
  "flash.nvim", "mini.ai", "mini.pairs", "grug-far.nvim", "trouble.nvim",
  "todo-comments.nvim", "persistence.nvim", "refactoring.nvim", "nvim-ts-autotag",
}
local dropped = { "ts-comments.nvim", "snacks.nvim", "noice.nvim", "telescope.nvim", "codeium.nvim", "claude-code.nvim" }
for _, name in ipairs(kept) do
  t.eq(plugins[name], true, name .. " installé et actif")
end
for _, name in ipairs(dropped) do
  t.eq(plugins[name], nil, name .. " absent")
end

t.ok(package.loaded.sidekick ~= nil, "sidekick chargé")
local ok_wt = pcall(require, "manu.worktree")
t.ok(ok_wt, "manu.worktree se charge")
t.ok(package.loaded.snacks == nil, "Snacks non chargé")
t.ok(not vim.inspect(require("manu.worktree")):find("Snacks"), "worktree sans Snacks")

local maps = {}
for _, mode in ipairs({ "n", "x" }) do
  for _, m in ipairs(vim.api.nvim_get_keymap(mode)) do
    maps[mode .. vim.fn.keytrans(m.lhsraw):gsub("^<Space>", "<leader>")] = true
  end
end
for _, k in ipairs({
  "n<leader>as", "n<leader>aS", "n<leader>ad", "n<leader>at", "x<leader>at", "n<leader>af",
  "x<leader>av", "n<leader>ai", "n<leader>aw", "n<leader>aW", "n<leader>ax", "n<leader>aa",
  "x<leader>aq", "n<leader>ap", "n<leader>aep", "n<leader>ar", "n<leader>yc",
  "ns", "nS", "n<leader>sr", "n<leader>xx", "n]t", "n<leader>qs", "x<leader>Re",
}) do
  t.ok(maps[k], "raccourci " .. k)
end

-- vim.ui.select reçoit bien « ● branche  ~/chemin » pour le worktree courant.
local captured
local select = vim.ui.select
vim.ui.select = function(items, opts)
  for _, item in ipairs(items) do
    local line = opts.format_item(item)
    if line:find("^● ") then
      captured = line
    end
  end
end
vim.cmd.cd(vim.fn.stdpath("config"))
require("manu.worktree").switch()
vim.ui.select = select
t.ok(captured and captured:find("^● "), "worktree courant marqué ● (" .. tostring(captured) .. ")")

t.finish()
