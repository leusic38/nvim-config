local corpus = require("nvimtrainer.corpus")
local engine = require("nvimtrainer.engine")
local verify = require("nvimtrainer.verify")
local session = require("nvimtrainer.session")
local progress = require("nvimtrainer.progress")

local M = {}

-- runtime session state
local cur = nil -- { exo, pool, done }

local function finish_current(result)
  if not cur or cur.done then return end
  cur.done = true
  progress.record(cur.exo.id, result)
  session.feedback(cur.exo, result)
end

local function attempt()
  if not cur or cur.done then return end
  local result = verify.check(cur.exo, engine.buf(), engine.captured())
  if result.passed then
    finish_current(result)
  end
end

-- Action keys are <localleader>-prefixed so they NEVER collide with the vim
-- keys the learner needs inside the scratch buffer (n, r, s, h are all real
-- motions/operators). Default localleader is `\`, so e.g. \n = next.
local function set_action_maps(buf)
  local function map(lhs, fn)
    vim.keymap.set("n", lhs, fn, { buffer = buf, nowait = true, silent = true })
  end
  map("<localleader>v", function()
    if not cur or cur.done then return end
    finish_current(verify.check(cur.exo, engine.buf(), engine.captured()))
  end)
  map("<localleader>q", function() M.stop() end)
  map("<localleader>s", function() if cur then session.feedback(cur.exo, { passed = false, technique = false }) end end)
  map("<localleader>h", function() if cur then session.render(cur.exo, true) end end)
  map("<localleader>r", function() if cur then engine.reset(cur.exo); cur.done = false; session.render(cur.exo, false) end end)
  map("<localleader>n", function() M.next() end)
end

function M.next()
  if not cur then return end
  local exo = progress.pick(cur.pool, progress.load())
  cur.exo = exo
  cur.done = false
  engine.start(exo, attempt)
  session.render(exo, false)
  set_action_maps(engine.buf())
end

-- category: optional string to filter the pool.
function M.start(category)
  local pool = category and corpus.by_category(category) or corpus.all()
  if #pool == 0 then
    vim.notify("NvimTrainer: aucun exercice", vim.log.levels.WARN)
    return
  end
  cur = { pool = pool }
  M.next()
end

function M.stop()
  cur = nil
  engine.stop()
  session.close()
end

function M.stats()
  local s = progress.stats(corpus.all())
  local msg = ("NvimTrainer — vus: %d · réussis: %d"):format(s.seen, s.passed)
  if #s.weak > 0 then
    msg = msg .. "\nPoints faibles:\n- " .. table.concat(s.weak, "\n- ")
  end
  vim.notify(msg, vim.log.levels.INFO)
end

function M.setup(opts)
  M.opts = opts or {}
  vim.api.nvim_create_user_command("NvimTrainerStart", function(a)
    M.start(a.args ~= "" and a.args or nil)
  end, { nargs = "?", complete = function()
    return { "motions", "textobjects", "excmd", "keymaps" }
  end })
  vim.api.nvim_create_user_command("NvimTrainerStop", function() M.stop() end, {})
  vim.api.nvim_create_user_command("NvimTrainerStats", function() M.stats() end, {})
end

return M
