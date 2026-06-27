local M = {}

local ns = vim.api.nvim_create_namespace("nvimtrainer_ui")
local float = nil -- { buf, win }

local WIDTH_MAX = 70

local function win_width()
  return math.max(20, math.min(WIDTH_MAX, vim.o.columns - 4))
end

-- How many screen rows `lines` occupy once wrapped at `width`.
local function wrapped_height(lines, width)
  local rows = 0
  for _, l in ipairs(lines) do
    local w = vim.fn.strdisplaywidth(l)
    rows = rows + math.max(1, math.ceil(w / width))
  end
  return rows
end

local function open_float(height)
  local width = win_width()
  if float and vim.api.nvim_win_is_valid(float.win) then
    vim.api.nvim_win_set_config(float.win, {
      relative = "editor",
      anchor = "NE",
      row = 1,
      col = vim.o.columns - 1,
      width = width,
      height = height,
    })
    return float
  end
  local buf = vim.api.nvim_create_buf(false, true)
  vim.bo[buf].bufhidden = "wipe"
  local win = vim.api.nvim_open_win(buf, false, {
    relative = "editor",
    anchor = "NE",
    row = 1,
    col = vim.o.columns - 1,
    width = width,
    height = height,
    style = "minimal",
    border = "rounded",
    title = " NvimTrainer ",
    focusable = false,
  })
  -- Wrap so long prompts (esp. keymap descriptions) are never truncated.
  vim.wo[win].wrap = true
  vim.wo[win].linebreak = true
  float = { buf = buf, win = win }
  return float
end

local function set(lines, hl)
  local width = win_width()
  local height = math.max(4, math.min(wrapped_height(lines, width), vim.o.lines - 4))
  local f = open_float(height)
  vim.api.nvim_buf_set_lines(f.buf, 0, -1, false, lines)
  vim.api.nvim_buf_clear_namespace(f.buf, ns, 0, -1)
  if hl then
    vim.api.nvim_buf_add_highlight(f.buf, ns, hl, 0, 0, -1)
  end
end

-- Spell out the in-scratch action keys with the real localleader prefix.
local function action_line()
  local ll = vim.g.maplocalleader or "\\"
  return ("Actions : %sv valider · %sh indice · %ss solution · %sr recommencer · %sn suivant · %sq quitter")
    :format(ll, ll, ll, ll, ll, ll)
end

-- One-line "what do I do?" instruction, tailored to the exercise kind.
local function howto(exo)
  if (exo.check or "state") == "keys" then
    return "▶ Exécute le raccourci / la séquence de touches demandé."
  end
  return "▶ Modifie le texte du buffer pour obtenir le résultat attendu (validé automatiquement)."
end

-- Show the active exercise prompt.
function M.render(exo, show_hint)
  local lines = {
    ("[%s · niv %d]"):format(exo.category, exo.difficulty),
    exo.title,
    "",
    howto(exo),
  }
  if show_hint and exo.hint then
    lines[#lines + 1] = "💡 " .. exo.hint
  end
  lines[#lines + 1] = ""
  lines[#lines + 1] = action_line()
  set(lines)
end

-- Show pass/fail feedback. result = { passed, technique }.
function M.feedback(exo, result)
  local ll = vim.g.maplocalleader or "\\"
  local lines = {}
  if result.passed then
    lines[#lines + 1] = "✓ Résultat correct"
  else
    lines[#lines + 1] = ("✗ Pas encore — %sr pour recommencer"):format(ll)
  end
  if exo.expected_keys then
    if result.technique then
      lines[#lines + 1] = "✓ Technique optimale (" .. exo.expected_keys .. ")"
    else
      lines[#lines + 1] = "○ Autre méthode (attendu : " .. exo.expected_keys .. ")"
    end
  end
  lines[#lines + 1] = ""
  lines[#lines + 1] = ("%sn suivant · %sr recommencer · %sq quitter"):format(ll, ll, ll)
  set(lines, result.passed and "DiagnosticOk" or "DiagnosticError")
end

function M.close()
  if float and vim.api.nvim_win_is_valid(float.win) then
    pcall(vim.api.nvim_win_close, float.win, true)
  end
  float = nil
end

return M
