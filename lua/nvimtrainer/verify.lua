local M = {}

-- Normalize an expected key string: resolve <leader>, <CR>, etc. to the raw
-- byte sequence that vim.on_key reports, so captured == normalized(expected).
local function normalize(keys)
  if not keys then return nil end
  local leader = vim.g.mapleader or "\\"
  keys = keys:gsub("<[lL]eader>", leader)
  return vim.api.nvim_replace_termcodes(keys, true, true, true)
end

local function lines_match(buf, target)
  local got = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
  if #got ~= #target then return false end
  for i = 1, #got do
    if got[i] ~= target[i] then return false end
  end
  return true
end

-- exo: the exercise table. buf: buffer handle. captured: raw on_key string.
-- Returns { passed = boolean, technique = boolean }.
function M.check(exo, buf, captured)
  local check = exo.check or "state"
  local keys_ok = false
  if exo.expected_keys then
    keys_ok = (captured == normalize(exo.expected_keys))
  end

  if check == "keys" then
    return { passed = keys_ok, technique = keys_ok }
  end

  local passed = lines_match(buf, exo.target_lines)
  if passed and exo.target_cursor then
    local cur = vim.api.nvim_win_get_cursor(0)
    passed = (cur[1] == exo.target_cursor[1] and cur[2] == exo.target_cursor[2])
  end
  return { passed = passed, technique = keys_ok }
end

return M
