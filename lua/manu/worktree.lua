-- Git worktrees : un onglet par worktree (:tcd), pour y faire tourner un agent
-- Claude séparé (les sessions sidekick sont indexées par répertoire courant).
-- Nouveaux worktrees créés à côté du dépôt : <repo>.worktrees/<branche>.

local M = {}

local function git(args, cwd)
  local res = vim.system(vim.list_extend({ "git" }, args), { cwd = cwd, text = true }):wait()
  if res.code ~= 0 then
    return nil, vim.trim(res.stderr ~= "" and res.stderr or res.stdout)
  end
  return vim.trim(res.stdout)
end

-- Racine du worktree principal (le dépôt d'origine), même depuis un worktree lié
local function main_root()
  local common = git({ "rev-parse", "--path-format=absolute", "--git-common-dir" }, vim.fn.getcwd())
  return common and vim.fs.dirname(common) or nil
end

---@return {path:string, branch:string, main:boolean}[]
local function list()
  local out, err = git({ "worktree", "list", "--porcelain" }, vim.fn.getcwd())
  if not out then
    vim.notify("worktree: " .. err, vim.log.levels.ERROR)
    return {}
  end
  local items, cur = {}, nil
  for line in (out .. "\n\n"):gmatch("([^\n]*)\n") do
    if line:match("^worktree ") then
      cur = { path = line:sub(10), branch = "(detached)", main = #items == 0 }
    elseif line:match("^branch ") and cur then
      cur.branch = line:sub(8):gsub("^refs/heads/", "")
    elseif line == "" and cur then
      items[#items + 1] = cur
      cur = nil
    end
  end
  return items
end

-- Ouvre le worktree dans son onglet (réutilisé s'il existe déjà)
---@param opts? {agent?:boolean}
function M.open(path, opts)
  path = vim.fs.normalize(path)
  for _, tab in ipairs(vim.api.nvim_list_tabpages()) do
    if vim.fs.normalize(vim.fn.getcwd(-1, vim.api.nvim_tabpage_get_number(tab))) == path then
      vim.api.nvim_set_current_tabpage(tab)
      if opts and opts.agent then
        require("manu.agent").toggle()
      end
      return
    end
  end
  vim.cmd.tabnew()
  vim.cmd.tcd(vim.fn.fnameescape(path))
  vim.cmd.edit(vim.fn.fnameescape(path))
  if opts and opts.agent then
    require("manu.agent").toggle()
  end
end

-- Choix d'un worktree via vim.ui.select (fzf-lua) : « ● branche  ~/chemin », ● = worktree courant.
local function pick(title, items, confirm)
  local cwd = vim.fs.normalize(vim.fn.getcwd())
  vim.ui.select(items, {
    prompt = title,
    format_item = function(item)
      local here = vim.fs.normalize(item.path) == cwd
      return (here and "● " or "  ") .. item.branch .. "  " .. vim.fn.fnamemodify(item.path, ":~")
    end,
  }, function(item)
    if item then
      confirm(item)
    end
  end)
end

function M.switch()
  pick("Worktrees", list(), function(wt)
    M.open(wt.path)
  end)
end

-- Crée un worktree (nouvelle branche depuis HEAD, ou branche existante) et y lance Claude
function M.create()
  local root = main_root()
  if not root then
    return vim.notify("worktree: pas dans un dépôt git", vim.log.levels.ERROR)
  end
  vim.ui.input({ prompt = "Branche du worktree: " }, function(branch)
    if not branch or vim.trim(branch) == "" then
      return
    end
    branch = vim.trim(branch)
    local path = root .. ".worktrees/" .. branch:gsub("/", "-")
    local exists = git({ "rev-parse", "--verify", "--quiet", "refs/heads/" .. branch }, root)
    local args = exists and { "worktree", "add", path, branch } or { "worktree", "add", "-b", branch, path }
    local _, err = git(args, vim.fn.getcwd())
    if err then
      return vim.notify("worktree: " .. err, vim.log.levels.ERROR)
    end
    vim.notify("worktree: " .. vim.fn.fnamemodify(path, ":~"))
    M.open(path, { agent = true })
  end)
end

-- Supprime un worktree lié (git refuse s'il a des modifications non commitées)
function M.remove()
  local items = vim.tbl_filter(function(wt)
    return not wt.main
  end, list())
  if #items == 0 then
    return vim.notify("worktree: aucun worktree lié")
  end
  pick("Supprimer un worktree", items, function(wt)
    if vim.fn.confirm("Supprimer " .. vim.fn.fnamemodify(wt.path, ":~") .. " ?", "&Oui\n&Non", 2) ~= 1 then
      return
    end
    local _, err = git({ "worktree", "remove", wt.path }, main_root())
    if err then
      return vim.notify("worktree: " .. err, vim.log.levels.ERROR)
    end
    vim.notify("worktree supprimé (branche " .. wt.branch .. " conservée)")
  end)
end

return M
