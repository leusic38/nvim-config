-- args: tests/fixtures/sample.md
-- Markdown : rendu dans le buffer (render-markdown) et aperçu navigateur (<leader>H).
local t = require("helpers")

t.eq(vim.bo.filetype, "markdown", "filetype markdown")
t.ok(package.loaded["render-markdown"] ~= nil, "render-markdown chargé")
t.ok(t.wait(function()
  return #vim.api.nvim_buf_get_extmarks(0, -1, 0, -1, { details = false }) > 0
end, 5000), "le buffer est décoré (rendu Markdown)")

-- <leader>H sur un fichier Markdown : mdview reçoit ce fichier, pas le manuel.
local called
local system = vim.system
vim.system = function(cmd, opts, cb)
  called = cmd
  return { wait = function() end }
end
for _, m in ipairs(vim.api.nvim_get_keymap("n")) do
  if m.lhs == " H" then
    m.callback()
  end
end
vim.system = system
t.eq(called and called[2], vim.api.nvim_buf_get_name(0), "<leader>H ouvre le fichier courant dans le navigateur")
t.finish()
