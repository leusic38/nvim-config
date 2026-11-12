-- Claude via sidekick, toujours celui du répertoire courant (:tcd de l'onglet).
-- Les helpers de sidekick prennent n'importe quelle session attachée : avec un
-- Claude par worktree, ils viseraient (ou demanderaient) le mauvais.

local M = {}

local TOOL = "claude"

local function here_attached()
  return require("sidekick.cli.state").get({ name = TOOL, cwd = true, attached = true })
end

-- Affiche/masque le Claude du cwd ; le démarre, ou reprend sa session tmux, s'il n'est pas attaché
function M.toggle()
  if #here_attached() > 0 then
    return require("sidekick.cli").toggle({ name = TOOL, filter = { cwd = true } })
  end
  local State = require("sidekick.cli.state")
  local cwd = require("sidekick.cli.session").cwd()
  -- triés par sidekick : session existante du cwd d'abord, sinon l'outil non démarré
  for _, state in ipairs(State.get({ name = TOOL })) do
    if not state.session or state.session.cwd == cwd then
      State.attach(state, { show = true, focus = true })
      return
    end
  end
end

---@param opts sidekick.cli.Send
function M.send(opts)
  if #here_attached() == 0 then
    vim.notify("Pas de Claude dans ce répertoire : je le démarre, renvoie ensuite.", vim.log.levels.WARN)
    return M.toggle()
  end
  require("sidekick.cli").send(vim.tbl_extend("force", opts, { name = TOOL, filter = { cwd = true } }))
end

function M.prompt()
  require("sidekick.cli").prompt(function(_, text)
    if text then
      M.send({ text = text })
    end
  end)
end

return M
