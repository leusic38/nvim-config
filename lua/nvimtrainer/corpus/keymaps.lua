local M = {}

-- Turn an lhs into an id-safe slug.
local function slug(s)
  return (s:gsub("[^%w]", function(c) return ("_%02x"):format(c:byte()) end))
end

-- Build a "keys" exercise per mapped keymap that has a non-empty desc.
-- mode defaults to normal mode.
function M.generate(mode)
  mode = mode or "n"
  local out = {}
  local seen = {}
  for _, map in ipairs(vim.api.nvim_get_keymap(mode)) do
    local desc = map.desc
    local lhs = map.lhs
    if desc and desc ~= "" and lhs and lhs ~= "" and not seen[lhs] then
      seen[lhs] = true
      out[#out + 1] = {
        id = "km-" .. mode .. "-" .. slug(lhs),
        title = "Quel raccourci pour : " .. desc .. " ? (exécute-le)",
        category = "keymaps",
        difficulty = 2,
        hint = desc,
        check = "keys",
        start_lines = { "Exécute le raccourci correspondant à la consigne." },
        start_cursor = { 1, 0 },
        expected_keys = lhs,
      }
    end
  end
  return out
end

return M
