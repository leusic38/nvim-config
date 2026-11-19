-- args: tests/fixtures/symfony/src/Controller/HomeController.php
-- PHP : Intelephense attaché, gd vers une classe, Treesitter, filtres de faux positifs.
local t = require("helpers")

t.eq(vim.bo.filetype, "php", "filetype php")
local attached = t.wait(function()
  return #vim.lsp.get_clients({ bufnr = 0, name = "intelephense" }) == 1
end, 120000)
t.ok(attached, "intelephense attaché (premier lancement : Mason l'installe)")
t.ok(t.wait(function()
  return vim.treesitter.get_parser(0, "php", { error = false }) ~= nil
end, 60000), "parser treesitter php")

local maps = {}
for _, m in ipairs(vim.api.nvim_buf_get_keymap(0, "n")) do
  maps[vim.fn.keytrans(m.lhsraw):gsub("^<Space>", "<leader>")] = m
end
for _, k in ipairs({ "gd", "gr", "K", "<leader>ca" }) do
  t.ok(maps[k], "raccourci LSP " .. k)
end

-- gd sur « Greeter » (ligne « use App\Service\Greeter; ») ouvre la classe.
local row = vim.fn.search([[\<Greeter\>]], "w")
t.ok(row > 0, "curseur sur Greeter")
local src = vim.api.nvim_buf_get_name(0)
-- Intelephense doit avoir indexé le projet avant de répondre.
t.wait(function()
  local done = false
  vim.lsp.buf_request_all(0, "textDocument/definition", function(client)
    return vim.lsp.util.make_position_params(0, client.offset_encoding)
  end, function(res)
    for _, r in pairs(res) do
      if r.result and (r.result.uri or r.result[1]) then
        done = true
      end
    end
  end)
  vim.wait(1500, function()
    return done
  end)
  return done
end, 60000)
maps["gd"].callback()
t.ok(t.wait(function()
  return vim.api.nvim_buf_get_name(0):match("src/Service/Greeter%.php$") ~= nil
end, 10000), "gd ouvre src/Service/Greeter.php")
t.ok(vim.api.nvim_buf_get_name(0) ~= src, "on a changé de fichier")

-- Filtres Intelephense (Symfony)
local filters = require("manu.php_filters")
t.ok(filters._should_hide({ message = "Undefined function 'dump'.", lnum = 0 }, 0, "symfony"), "dump() masqué (Symfony)")
t.ok(not filters._should_hide({ message = "Undefined function 'foo'.", lnum = 0 }, 0, "symfony"), "foo() gardé")

t.finish()
