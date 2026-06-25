local schema = require("nvimtrainer.corpus.schema")

local M = {}

local STATIC = { "motions", "textobjects", "excmd" }

-- opts.include_keymaps (default true): include auto-extracted keymap exercises.
function M.all(opts)
  opts = opts or {}
  local include_keymaps = opts.include_keymaps ~= false
  local list = {}
  for _, name in ipairs(STATIC) do
    for _, exo in ipairs(require("nvimtrainer.corpus." .. name)) do
      list[#list + 1] = exo
    end
  end
  if include_keymaps then
    for _, exo in ipairs(require("nvimtrainer.corpus.keymaps").generate("n")) do
      list[#list + 1] = exo
    end
  end
  local ok, err = schema.validate(list)
  if not ok then
    error("nvimtrainer corpus invalid: " .. err)
  end
  return list
end

function M.by_category(cat, opts)
  local out = {}
  for _, exo in ipairs(M.all(opts)) do
    if exo.category == cat then
      out[#out + 1] = exo
    end
  end
  return out
end

return M
