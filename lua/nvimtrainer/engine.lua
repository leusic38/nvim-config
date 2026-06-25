local M = {}

local ns = vim.api.nvim_create_namespace("nvimtrainer_keycap")

-- state: { buf, win, captured, on_validate }
local state = nil

-- Open a disposable scratch window seeded with the exercise start state.
-- on_validate() is called whenever a candidate validation should run.
function M.start(exo, on_validate)
  M.stop() -- clean any previous session

  local buf = vim.api.nvim_create_buf(false, true)
  vim.bo[buf].buftype = "nofile"
  vim.bo[buf].bufhidden = "wipe"
  vim.bo[buf].swapfile = false
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, exo.start_lines)
  vim.bo[buf].filetype = exo.filetype or "text"

  vim.cmd("botright split")
  local win = vim.api.nvim_get_current_win()
  vim.api.nvim_win_set_buf(win, buf)
  vim.api.nvim_win_set_height(win, math.max(#exo.start_lines + 2, 6))
  pcall(vim.api.nvim_win_set_cursor, win, exo.start_cursor or { 1, 0 })

  state = { buf = buf, win = win, captured = "", on_validate = on_validate }

  -- Capture every typed key (pre-mapping) into state.captured, and trigger a
  -- validation pass after each key. This covers BOTH exercise kinds:
  --   - keys-exos: no buffer change, so on_key is the only reliable trigger.
  --   - state-exos: harmless extra checks; buffer comparison just won't match
  --     until the edit completes.
  -- vim.schedule defers on_validate out of the fast on_key context (where most
  -- API calls are forbidden).
  vim.on_key(function(_, typed)
    if not state then return end
    if typed and typed ~= "" then
      state.captured = state.captured .. typed
    end
    if state.on_validate then
      vim.schedule(function()
        if state and state.on_validate then state.on_validate() end
      end)
    end
  end, ns)

  vim.api.nvim_set_current_win(win)
end

function M.captured()
  return state and state.captured or ""
end

function M.buf()
  return state and state.buf or nil
end

-- Reset buffer back to the start state (used by "recommencer").
function M.reset(exo)
  if not state then return end
  vim.api.nvim_buf_set_lines(state.buf, 0, -1, false, exo.start_lines)
  state.captured = ""
  pcall(vim.api.nvim_win_set_cursor, state.win, exo.start_cursor or { 1, 0 })
end

function M.stop()
  if not state then return end
  vim.on_key(nil, ns)
  if state.win and vim.api.nvim_win_is_valid(state.win) then
    pcall(vim.api.nvim_win_close, state.win, true)
  end
  state = nil
end

return M
