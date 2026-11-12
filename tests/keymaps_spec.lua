-- verbose
-- Origine et documentation des raccourcis globaux :
-- (1) chaque raccourci global (n x o i t) vient de la config ou du runtime Neovim,
--     sauf la liste blanche ALLOWED ;
-- (2) chaque raccourci de la config a une desc et figure dans KEYMAPS.md avec ses modes ;
-- (3) chaque ligne de KEYMAPS.md hors sections « (buffer) » existe.
-- La 1re ligne « -- verbose » fait lancer nvim avec verbose=1 (tests/run.sh) :
-- nvim note alors le fichier qui pose chaque raccourci.
local t = require("helpers")

-- Buffer neuf : les raccourcis locaux de l'accueil ne doivent pas se mêler à « verbose map ».
vim.cmd("enew")

-- Plugins autorisés à poser des raccourcis globaux, par mode. N'étendre que si une
-- tâche l'exige, avec la raison en commentaire.
local ALLOWED = {
  -- Objets textuels a/i et g[ / g] (aller au bord d'un objet) : posés par mini.ai lui-même.
  ["mini.ai"] = { "n", "o", "x" },
  -- f t F T ; , améliorés (sauts sur plusieurs lignes) : mode « char » de flash, retenu au tri.
  ["flash.nvim"] = { "n", "o", "x" },
  -- ( ) [ ] { } " ' ` <BS> <CR> en insertion : fermeture des paires, retenue au tri.
  ["mini.pairs"] = { "i" },
}

local MODES = { "n", "x", "o", "i", "t" }
local config = vim.fn.stdpath("config")
local config_real = vim.uv.fs_realpath(config) or config
local runtime = vim.env.VIMRUNTIME

-- Raccourcis par défaut de Neovim (nvim --clean) : leur origine n'est pas toujours connue.
local defaults = {}
do
  local script = "local o={} for _,m in ipairs({'n','x','o','i','t'}) do for _,k in ipairs(vim.api.nvim_get_keymap(m)) do o[#o+1]=m..vim.fn.keytrans(k.lhsraw) end end io.stdout:write(vim.json.encode(o)) vim.cmd('qa!')"
  local res = vim.system({ vim.v.progpath, "--clean", "--headless", "-c", "lua " .. script }, { text = true }):wait(30000)
  for _, k in ipairs(vim.json.decode(res.stdout ~= "" and res.stdout or "[]")) do
    defaults[k] = true
  end
end

local function starts(s, p)
  return s and s:sub(1, #p) == p
end

--- Fichier qui a posé le raccourci.
local function origin_file(mode, map)
  if map.callback then
    local src = debug.getinfo(map.callback, "S").source
    if src:sub(1, 1) == "@" then
      return vim.fs.normalize(src:sub(2))
    end
  end
  local ok, res = pcall(vim.api.nvim_exec2, "verbose " .. mode .. "map " .. vim.fn.keytrans(map.lhsraw), { output = true })
  if ok then
    local file = res.output:match("Last set from ([^\n]-) line %d+")
      or res.output:match("dans ([^\n]-) line %d+")
    if file then
      return vim.fs.normalize(file)
    end
  end
  return nil
end

local function kind(file)
  if not file then
    return "inconnu"
  end
  if starts(file, config .. "/") or starts(file, config_real .. "/") then
    return "config"
  end
  if starts(file, runtime) or file:find("^vim/") or file:find("vim/_core/", 1, true) then
    return "runtime"
  end
  for name in pairs(ALLOWED) do
    if file:find("/" .. name .. "/", 1, true) then
      return name
    end
  end
  return file
end

-- ─── Lecture de KEYMAPS.md ─────────────────────────────────────────────────
local doc = {} -- lhsraw → { modes = set, line = string }
local doc_lines = vim.fn.readfile(config .. "/KEYMAPS.md")
local buffer_section = false
for _, line in ipairs(doc_lines) do
  local title = line:match("^#+%s+(.*)$")
  if title then
    buffer_section = title:find("%(buffer%)%s*$") ~= nil
  elseif not buffer_section and line:match("^|%s*`") then
    local cells = vim.split(line, "|", { plain = true })
    local key = vim.trim(cells[2]):gsub("^`+%s?", ""):gsub("%s?`+$", "")
    local modes = vim.trim(cells[3] or "")
    -- replace_termcodes donne <NL> pour <C-j> et <C-\> pour <C-Bslash> ; nvim garde <C-J>/<C-Bslash>.
    local raw = vim.fn.keytrans(vim.api.nvim_replace_termcodes(key, true, true, true)):gsub("<NL>", "<C-J>"):gsub("<C%-\\>", "<C-Bslash>")
    doc[raw] = doc[raw] or { modes = {}, key = key }
    for m in modes:gmatch("%a") do
      doc[raw].modes[m] = true
    end
  end
end
t.ok(next(doc) ~= nil, "KEYMAPS.md contient des raccourcis")

-- ─── (1) et (2) ────────────────────────────────────────────────────────────
local from_config = {} -- lhsraw → set de modes
for _, mode in ipairs(MODES) do
  for _, map in ipairs(vim.api.nvim_get_keymap(mode)) do
    if not map.lhs:find("^<Plug>") and not map.lhs:find("^<SNR>") then
      local key = vim.fn.keytrans(map.lhsraw)
      local k = kind(origin_file(mode, map))
      if k == "inconnu" and defaults[mode .. key] then
        k = "runtime"
      end
      local name = vim.fn.keytrans(map.lhsraw)
      if k == "config" then
        from_config[key] = from_config[key] or {}
        from_config[key][mode] = true
        t.ok(map.desc and map.desc ~= "", "desc pour " .. mode .. " " .. name)
      elseif k ~= "runtime" then
        local allowed = ALLOWED[k] and vim.tbl_contains(ALLOWED[k], mode)
        t.ok(allowed, "raccourci global non déclaré : " .. mode .. " " .. name .. " (origine " .. k .. ")")
      end
    end
  end
end

for raw, modes in pairs(from_config) do
  local name = raw:gsub("^<Space>", "<leader>")
  local entry = doc[raw]
  if t.ok(entry, "KEYMAPS.md liste " .. name) then
    t.eq(entry.modes, modes, "modes de " .. name .. " dans KEYMAPS.md")
  end
end

-- ─── (3) ───────────────────────────────────────────────────────────────────
for raw, entry in pairs(doc) do
  for m in pairs(entry.modes) do
    t.ok(from_config[raw] and from_config[raw][m], "raccourci documenté existant : " .. m .. " " .. entry.key)
  end
end

t.finish()
