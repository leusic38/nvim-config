local M = {}

local function path()
  local dir = vim.fn.stdpath("data") .. "/nvimtrainer"
  vim.fn.mkdir(dir, "p")
  return dir .. "/progress.json"
end

-- Weight: unseen entries are heaviest; failures raise weight, passes lower it.
function M.weight(entry)
  if not entry or (entry.seen or 0) == 0 then
    return 10
  end
  local w = 1 + (entry.failed or 0) * 3 - math.min(entry.passed or 0, 5) * 0.5
  return math.max(w, 0.5)
end

-- Mutates `data` in place. ts is a unix timestamp (injected for testability).
function M.record_into(data, id, result, ts)
  local e = data[id] or { seen = 0, passed = 0, failed = 0, technique_hits = 0 }
  e.seen = e.seen + 1
  if result.passed then
    e.passed = e.passed + 1
  else
    e.failed = e.failed + 1
  end
  if result.technique then
    e.technique_hits = e.technique_hits + 1
  end
  e.last_ts = ts
  data[id] = e
  return data
end

-- Weighted random pick. rng(n) must return a number in [0, n]; defaults to
-- math.random (fine at plugin runtime, injected in tests).
function M.pick(exos, data, rng)
  rng = rng or function(n) return math.random() * n end
  local total = 0
  local weights = {}
  for i, exo in ipairs(exos) do
    weights[i] = M.weight(data[exo.id])
    total = total + weights[i]
  end
  local r = rng(total)
  local acc = 0
  for i, exo in ipairs(exos) do
    acc = acc + weights[i]
    if r <= acc then
      return exo
    end
  end
  return exos[#exos]
end

function M.load()
  local p = path()
  local fd = io.open(p, "r")
  if not fd then return {} end
  local raw = fd:read("*a")
  fd:close()
  if raw == "" then return {} end
  local ok, decoded = pcall(vim.json.decode, raw)
  return ok and decoded or {}
end

function M.save(data)
  local fd = io.open(path(), "w")
  if not fd then return end
  fd:write(vim.json.encode(data))
  fd:close()
end

-- Convenience used at runtime: load, record with os.time(), save.
function M.record(id, result)
  local data = M.load()
  M.record_into(data, id, result, os.time())
  M.save(data)
end

function M.stats(exos)
  local data = M.load()
  local total_passed, total_seen, weak = 0, 0, {}
  for _, exo in ipairs(exos) do
    local e = data[exo.id]
    if e then
      total_seen = total_seen + (e.seen or 0)
      total_passed = total_passed + (e.passed or 0)
      if (e.failed or 0) > (e.passed or 0) then
        weak[#weak + 1] = exo.title
      end
    end
  end
  return { seen = total_seen, passed = total_passed, weak = weak }
end

return M
