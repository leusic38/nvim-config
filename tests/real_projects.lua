-- Corps de tests/real_projects.sh (exécuté dans nvim, buffer courant = un fichier PHP).
local out = {}
local function say(fmt, ...)
  local line = fmt:format(...)
  io.stdout:write(line .. "\n")
  io.stdout:flush()
  table.insert(out, line)
end
local function wait(ms, cond)
  return vim.wait(ms, function()
    local ok, res = pcall(cond)
    return ok and res
  end, 500)
end
local t0 = vim.uv.hrtime()
local function elapsed()
  return ("%.0f s"):format((vim.uv.hrtime() - t0) / 1e9)
end

-- :Projet
for _, l in ipairs(require("manu.project").describe()) do
  say("  %s", l)
end

-- Intelephense + gd sur le premier « use » d'une classe du projet.
local ok = wait(120000, function()
  return #vim.lsp.get_clients({ bufnr = 0, name = "intelephense" }) > 0
end)
say("Intelephense attaché : %s (%s)", tostring(ok), elapsed())
local row = vim.fn.search([[^use \u\a\+\\]], "w")
if row > 0 then
  vim.cmd("normal! $b")
  local src = vim.api.nvim_buf_get_name(0)
  local cls = vim.fn.expand("<cword>")
  local jumped = wait(600000, function()
    local done
    vim.lsp.buf_request_all(0, "textDocument/definition", function(client)
      return vim.lsp.util.make_position_params(0, client.offset_encoding)
    end, function(res)
      for _, r in pairs(res) do
        if r.result and (r.result.uri or r.result[1]) then
          done = true
        end
      end
      done = done or false
    end)
    vim.wait(3000, function()
      return done ~= nil
    end)
    return done
  end)
  say("gd sur %s : %s (%s)", cls, jumped and "définition trouvée" or "RIEN", elapsed())
  if jumped then
    -- Le gd de la config (dédoublonne Intelephense + symfony-lsp).
    for _, m in ipairs(vim.api.nvim_buf_get_keymap(0, "n")) do
      if m.lhs == "gd" then
        m.callback()
      end
    end
    wait(10000, function()
      return vim.api.nvim_buf_get_name(0) ~= src
    end)
    say("  → %s", vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ":~:."))
    vim.cmd("edit " .. vim.fn.fnameescape(src))
  end
end

-- PHPStan sur le fichier (sans enregistrer).
local lint = require("lint")
if require("manu.lint").names_for(0, "BufWritePost")[1] then
  lint.try_lint("phpstan_project")
  wait(180000, function()
    return #lint.get_running(0) == 0
  end)
  local n = #vim.diagnostic.get(0, { namespace = lint.get_namespace("phpstan_project") })
  say("PHPStan : %d diagnostic(s) (%s)", n, elapsed())
else
  say("PHPStan : non lancé (pas de config, ou conteneur arrêté)")
end

-- Tests vus par neotest, sur un fichier de test du projet.
local nt = require("neotest")
if vim.env.MANU_REAL_TEST ~= "" then
  vim.cmd("edit " .. vim.fn.fnameescape(vim.env.MANU_REAL_TEST))
  local file = vim.api.nvim_buf_get_name(0)
  -- Le client neotest démarre au premier usage (ici : ouvrir le résumé).
  nt.summary.open()
  vim.cmd("wincmd p")
  local found = wait(120000, function()
    for _, id in ipairs(nt.state.adapter_ids()) do
      local tree = nt.state.positions(id, { buffer = 0 })
      if tree then
        return tree
      end
    end
  end)
  local n = 0
  if found then
    for _, pos in found:iter() do
      n = n + (pos.type == "test" and 1 or 0)
    end
  end
  say("neotest : %d test(s) trouvé(s) dans %s (adaptateurs : %s)", n, vim.fn.fnamemodify(file, ":."), table.concat(nt.state.adapter_ids(), ", "))
end

-- symfony-lsp sur un services.yaml
local yaml = vim.env.MANU_REAL_YAML
if yaml and yaml ~= "" then
  vim.cmd("edit " .. vim.fn.fnameescape(yaml))
  local att = wait(60000, function()
    return #vim.lsp.get_clients({ bufnr = 0, name = "symfony_lsp" }) > 0
  end)
  say("symfony-lsp sur %s : %s", yaml, tostring(att))
end

say("Terminé en %s.", elapsed())
vim.cmd("qa!")
