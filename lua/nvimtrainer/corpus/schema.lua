local M = {}

local REQUIRED = { "id", "title", "category", "difficulty", "start_lines" }

-- Returns ok(boolean), err(string|nil)
function M.validate(list)
  local seen = {}
  for i, exo in ipairs(list) do
    for _, field in ipairs(REQUIRED) do
      if exo[field] == nil then
        return false, ("exercise #%d missing required field '%s'"):format(i, field)
      end
    end
    if seen[exo.id] then
      return false, ("duplicate id '%s'"):format(exo.id)
    end
    seen[exo.id] = true

    local check = exo.check or "state"
    if check == "state" and exo.target_lines == nil then
      return false, ("exercise '%s' (check=state) missing target_lines"):format(exo.id)
    end
    if check == "keys" and exo.expected_keys == nil then
      return false, ("exercise '%s' (check=keys) missing expected_keys"):format(exo.id)
    end
  end
  return true, nil
end

return M
