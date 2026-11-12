-- Petites assertions pour les tests headless de neovimanu.
-- Usage dans un spec : local t = require("helpers") … t.finish()
local M = { passed = 0, failed = 0 }

local function report(ok, msg, detail)
  if ok then
    M.passed = M.passed + 1
  else
    M.failed = M.failed + 1
    io.stdout:write("  ✗ " .. msg .. (detail and ("\n      " .. detail) or "") .. "\n")
  end
  return ok
end

---@param cond any
---@param msg string
function M.ok(cond, msg)
  return report(cond and true or false, msg)
end

---@param actual any
---@param expected any
---@param msg string
function M.eq(actual, expected, msg)
  local ok = vim.deep_equal(actual, expected)
  return report(ok, msg, not ok and ("attendu " .. vim.inspect(expected) .. ", obtenu " .. vim.inspect(actual)) or nil)
end

--- Attend que cond() soit vrai (boucle d'événements active).
---@param cond fun(): boolean
---@param ms? integer
---@return boolean
function M.wait(cond, ms)
  return vim.wait(ms or 10000, function()
    local ok, res = pcall(cond)
    return ok and res and true or false
  end, 50) == true
end

--- Écrit le bilan et quitte : 0 si tout passe, 1 sinon.
function M.finish()
  io.stdout:write(string.format("  %d ok, %d échec(s)\n", M.passed, M.failed))
  io.stdout:flush()
  if M.failed == 0 then
    vim.cmd("qa!")
  else
    vim.cmd("cquit 1")
  end
end

return M
