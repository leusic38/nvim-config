local M = {}

local ns = vim.api.nvim_create_namespace("nvimtrainer_ui")
local float = nil -- { buf, win }

local function open_float()
  if float and vim.api.nvim_win_is_valid(float.win) then return float end
  local buf = vim.api.nvim_create_buf(false, true)
  vim.bo[buf].bufhidden = "wipe"
  local width = math.min(80, vim.o.columns - 4)
  local win = vim.api.nvim_open_win(buf, false, {
    relative = "editor",
    anchor = "NE",
    row = 1,
    col = vim.o.columns - 1,
    width = width,
    height = 8,
    style = "minimal",
    border = "rounded",
    title = " NvimTrainer ",
    focusable = false,
  })
  float = { buf = buf, win = win }
  return float
end

local function set(lines, hl)
  local f = open_float()
  vim.api.nvim_buf_set_lines(f.buf, 0, -1, false, lines)
  vim.api.nvim_buf_clear_namespace(f.buf, ns, 0, -1)
  if hl then
    vim.api.nvim_buf_add_highlight(f.buf, ns, hl, 0, 0, -1)
  end
end

-- Show the active exercise prompt.
function M.render(exo, show_hint)
  local lines = {
    ("[%s · niv %d]  %s"):format(exo.category, exo.difficulty, exo.title),
    "",
  }
  if show_hint and exo.hint then
    lines[#lines + 1] = "💡 " .. exo.hint
  end
  lines[#lines + 1] = ""
  lines[#lines + 1] = "n suivant · r recommencer · s solution · h indice · q quitter"
  set(lines)
end

-- Show pass/fail feedback. result = { passed, technique }.
function M.feedback(exo, result)
  local lines = {}
  if result.passed then
    lines[#lines + 1] = "✓ Résultat correct"
  else
    lines[#lines + 1] = "✗ Pas encore — réessaie (r pour recommencer)"
  end
  if exo.expected_keys then
    if result.technique then
      lines[#lines + 1] = "✓ Technique optimale (" .. exo.expected_keys .. ")"
    else
      lines[#lines + 1] = "○ Autre méthode (attendu : " .. exo.expected_keys .. ")"
    end
  end
  lines[#lines + 1] = ""
  lines[#lines + 1] = "n suivant · r recommencer · q quitter"
  set(lines, result.passed and "DiagnosticOk" or "DiagnosticError")
end

function M.close()
  if float and vim.api.nvim_win_is_valid(float.win) then
    pcall(vim.api.nvim_win_close, float.win, true)
  end
  float = nil
end

return M
