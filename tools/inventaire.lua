-- Inventaire des raccourcis et plugins de l'ancienne config LazyVim, pour le tri.
--
-- À lancer DANS l'ancienne config (appname par défaut), depuis le worktree neovimanu :
--   nvim --headless --cmd "set verbose=1" \
--     -c "lua vim.g.inventaire_out='$PWD/docs/tri.md'" -c "luafile tools/inventaire.lua" 2>/dev/null
-- (« verbose=1 » dès le démarrage : nvim note alors le fichier qui pose chaque raccourci.)
--
-- Écrit docs/tri.md : une checklist par domaine, pré-cochée pour ce qui est « perso ».

vim.cmd("silent! language messages C")

local uv = vim.uv
local out_path = vim.g.inventaire_out or (vim.fn.getcwd() .. "/docs/tri.md")
local config_dirs = { vim.fn.stdpath("config"), uv.fs_realpath(vim.fn.stdpath("config")) }
local lazy_root = require("lazy.core.config").options.root
local lazyvim_dir = lazy_root .. "/LazyVim/lua/lazyvim"
local runtime = vim.env.VIMRUNTIME
local MODES = { "n", "x", "o", "i", "t" }

-- ─── Outils ────────────────────────────────────────────────────────────────

local function starts(s, prefix)
  return s ~= nil and prefix ~= nil and s:sub(1, #prefix) == prefix
end

local function under_config(path)
  for _, d in ipairs(config_dirs) do
    if d and starts(path, d .. "/") then
      return true
    end
  end
  return false
end

local function read(path)
  local f = io.open(path, "r")
  if not f then
    return ""
  end
  local s = f:read("*a")
  f:close()
  return s
end

local function lua_files(dir)
  return vim.fs.find(function(name)
    return name:match("%.lua$")
  end, { path = dir, type = "file", limit = math.huge })
end

--- Index : touche normalisée (octets bruts) → liste de fichiers qui la citent entre guillemets.
--- strict : seulement en tête d'une spec `{ "touche", … }` (keys de lazy.nvim).
local function build_index(dir, strict)
  local index = {}
  local pats = strict and { '{%s*"([^"\n]+)"', "{%s*'([^'\n]+)'" } or { '"([^"\n]+)"', "'([^'\n]+)'" }
  for _, file in ipairs(lua_files(dir)) do
    local seen = {}
    local src = read(file)
    for _, pat in ipairs(pats) do
      for s in src:gmatch(pat) do
        if #s <= 30 and not seen[s] then
          seen[s] = true
          local ok, raw = pcall(vim.api.nvim_replace_termcodes, s, true, true, true)
          if ok and raw ~= "" then
            index[raw] = index[raw] or {}
            table.insert(index[raw], file)
          end
        end
      end
    end
  end
  return index
end

local perso_index = {}
for _, d in ipairs(config_dirs) do
  if d then
    perso_index = vim.tbl_extend("keep", perso_index, build_index(d .. "/lua", true))
    break
  end
end
local lazyvim_index = build_index(lazyvim_dir)
-- Pour les raccourcis par filetype (buffer-local) : toute citation entre guillemets compte.
local perso_index_loose = build_index(config_dirs[1] .. "/lua")

--- Raccourcis par défaut de Neovim (nvim --clean) : mode .. lhsraw → desc.
local defaults = {}
do
  local script = [[
    local out = {}
    for _, mode in ipairs({ "n", "x", "o", "i", "t" }) do
      for _, m in ipairs(vim.api.nvim_get_keymap(mode)) do
        out[#out + 1] = { mode = mode, lhs = m.lhsraw, desc = m.desc or m.rhs or "" }
      end
    end
    io.stdout:write(vim.json.encode(out))
    vim.cmd("qa!")
  ]]
  local res = vim.system({ vim.v.progpath, "--clean", "--headless", "-c", "lua " .. script:gsub("\n", " ") }, { text = true }):wait(30000)
  local ok, list = pcall(vim.json.decode, res.stdout or "")
  if ok and type(list) == "table" then
    for _, m in ipairs(list) do
      defaults[m.mode .. m.lhs] = m.desc
    end
  end
end

local function is_default(mode, map)
  local d = defaults[mode .. map.lhsraw]
  return d ~= nil and (d == (map.desc or map.rhs or "") or d == "" or (map.desc or ""):find(":help", 1, true) ~= nil)
end

--- Origine LazyVim d'après le fichier : « LazyVim » ou « LazyVim (extra <nom>) ».
local function lazyvim_origin(file)
  local extra = file:match("/plugins/extras/(.+)%.lua$")
  if extra then
    return "LazyVim (extra " .. extra:gsub("/", ".") .. ")"
  end
  return "LazyVim"
end

local function lazyvim_from_index(raw)
  local files = lazyvim_index[raw]
  if not files then
    return nil
  end
  -- Préférer le cœur aux extras s'il le cite.
  for _, f in ipairs(files) do
    if not f:find("/extras/") then
      return "LazyVim"
    end
  end
  return lazyvim_origin(files[1])
end

--- Fichier qui a posé le raccourci (verbose map), ou source de la callback.
local function set_from(mode, map, buffer)
  local cmd = "verbose " .. mode .. "map " .. (buffer and "<buffer> " or "") .. map.lhs
  local ok, res = pcall(vim.api.nvim_exec2, cmd, { output = true })
  if ok then
    local file = res.output:match("Last set from ([^\n]-) line %d+")
    if file then
      return vim.fs.normalize(file)
    end
  end
  if map.callback then
    local src = debug.getinfo(map.callback, "S").source
    return (src:gsub("^@", ""))
  end
end

--- Plugin lazy.nvim qui déclare cette touche dans ses `keys`.
local function lazy_owner(mode, map)
  local Keys = require("lazy.core.handler.keys")
  for name, plugin in pairs(require("lazy.core.config").plugins) do
    for _, k in pairs((plugin._.handlers or {}).keys or {}) do
      if k.mode == mode and Keys.parse({ k.lhs }).id == map.lhsraw and not k.ft then
        return name
      end
    end
  end
end

local function is_runtime(file)
  return file
    and (starts(file, runtime) or file:find("vim/_core/", 1, true) or file:find("^vim/") or file:find("/runtime/lua/"))
end

--- Origine d'un raccourci global, ou nil s'il vient du runtime (à ignorer).
local function origin_of(mode, map)
  if is_default(mode, map) then
    return nil
  end
  local file = set_from(mode, map)
  if is_runtime(file) then
    return nil
  end
  if file and under_config(file) then
    return "perso"
  end
  if file and file:find("/LazyVim/", 1, true) then
    return lazyvim_origin(file)
  end
  if perso_index[map.lhsraw] then
    return "perso"
  end
  local lv = lazyvim_from_index(map.lhsraw)
  if lv then
    return lv
  end
  local owner = file and file:find("lazy/core/handler/keys.lua", 1, true) and lazy_owner(mode, map)
  if owner then
    return "plugin " .. owner
  end
  local plugin = file and file:match("/lazy/([^/]+)/")
  if plugin then
    return "plugin " .. plugin
  end
  return "autres"
end

--- Affichage : <leader> au lieu de l'espace.
local function show(lhs_raw)
  local s = vim.fn.keytrans(lhs_raw)
  s = s:gsub("^<Space>", "<leader>")
  return s
end

-- ─── Domaines ──────────────────────────────────────────────────────────────

local DOMAINS = {
  "fenêtres",
  "buffers",
  "fichiers",
  "recherche",
  "code/LSP",
  "git",
  "terminal",
  "ui/toggles",
  "édition",
  "debug/tests",
  "IA",
  "langages",
  "autres",
}

local function domain_of(lhs, desc, ft)
  desc = (desc or ""):lower()
  if ft then
    return "langages"
  end
  if desc:find("terminal") or desc:find("lazydocker") or lhs:find("^<leader>t[fhv]$") or lhs == "<C-/>" or lhs == "<C-_>" or lhs == "<C-\\>" then
    return "terminal"
  end
  if lhs:find("^<leader>w") or lhs:find("^<C%-[HJKLhjkl]>$") or lhs:find("^<C%-[UD][po]") or lhs:find("^<C%-Up>") or lhs:find("^<C%-Down>") or lhs:find("^<C%-Left>") or lhs:find("^<C%-Right>") or lhs == "<leader>-" or lhs == "<leader>|" or desc:find("window") then
    return "fenêtres"
  end
  if lhs:find("^<leader>b") or lhs:find("^[%[%]]b$") or lhs == "H" or lhs == "L" or lhs:find("^[%[%]][bB]") or lhs == "<leader>`" or lhs == "<leader>," or lhs:find("^<leader><Tab>") or desc:find("buffer") then
    return "buffers"
  end
  if lhs:find("^<leader>g") or lhs:find("^[%[%]][hH]$") or desc:find("git") or desc:find("hunk") or desc:find("diffview") then
    return "git"
  end
  if lhs:find("^<leader>a") or desc:find("sidekick") or desc:find("claude") or desc:find("codeium") or desc:find("copilot") then
    return "IA"
  end
  if lhs:find("^<leader>u") then
    return "ui/toggles"
  end
  if lhs:find("^<leader>d") or lhs:find("^<leader>t") or desc:find("debug") or desc:find("breakpoint") or desc:find("test") then
    return "debug/tests"
  end
  if lhs:find("^<leader>f") or lhs:find("^<leader>[eE]$") or lhs == "-" or desc:find("explorer") or desc:find("file") then
    return "fichiers"
  end
  if lhs:find("^<leader>s") or lhs == "<leader>/" or lhs == "<leader><leader>" or lhs == "<leader>:" or desc:find("grep") or desc:find("search") then
    return "recherche"
  end
  if lhs:find("^<leader>c") or lhs:find("^<leader>x") or lhs:find("^g[dDrIyKO]") or lhs:find("^[%[%]][dewq]$") or desc:find("diagnostic") or desc:find("quickfix") or desc:find("lsp") or desc:find("symbol") then
    return "code/LSP"
  end
  if lhs:find("^<leader>r") or lhs:find("^g[cs]") or lhs:find("^<A%-[jk]>") or lhs:find("^[sS]$") or lhs == "<C-S>" or lhs == "<lt>" or lhs == ">" or lhs:find("^[%[%]]t$") or desc:find("comment") or desc:find("flash") or desc:find("refactor") or desc:find("replace") or desc:find("move") or desc:find("save") or desc:find("todo") or desc:find("undo") or desc:find("select") then
    return "édition"
  end
  return "autres"
end

-- ─── Collecte ──────────────────────────────────────────────────────────────

local rows = {} ---@type table<string, {mode:string, lhs:string, desc:string, origin:string, domain:string}>
local order = {}

local function add_row(mode, lhs, desc, origin, ft)
  local key = lhs .. "\0" .. (ft or "") .. "\0" .. origin
  local row = rows[key]
  if row then
    if not row.mode:find(mode, 1, true) then
      row.mode = row.mode .. mode
    end
    return
  end
  desc = (desc or ""):gsub("|", "\\|"):gsub("\n", " ")
  if ft then
    desc = desc .. " [" .. ft .. "]"
  end
  rows[key] = { mode = mode, lhs = lhs, desc = desc, origin = origin, domain = domain_of(lhs, desc, ft) }
  table.insert(order, key)
end

local function skip(map)
  return map.lhs:find("^<Plug>") or map.lhs:find("^<SNR>") or (map.desc or ""):find("^which%-key%-trigger")
end

local function collect_globals()
  for _, mode in ipairs(MODES) do
    for _, map in ipairs(vim.api.nvim_get_keymap(mode)) do
      if not skip(map) then
        local origin = origin_of(mode, map)
        if origin then
          add_row(mode, show(map.lhsraw), map.desc, origin)
        end
      end
    end
  end
end

--- Raccourcis LSP de LazyVim (servers['*'].keys) et ceux propres à un serveur.
local function collect_lsp()
  local ok, opts = pcall(function()
    return LazyVim.opts("nvim-lspconfig")
  end)
  if not ok or type(opts) ~= "table" then
    return
  end
  local Keys = require("lazy.core.handler.keys")
  for server, conf in pairs(opts.servers or {}) do
    if type(conf) == "table" and conf.keys then
      for _, k in pairs(Keys.resolve(conf.keys)) do
        local raw = vim.api.nvim_replace_termcodes(k.lhs, true, true, true)
        local origin
        if perso_index[raw] and server ~= "*" then
          origin = "perso"
        elseif server == "*" then
          origin = "LazyVim (LSP)"
        else
          origin = lazyvim_from_index(raw) or "LazyVim (LSP)"
        end
        local desc = k.desc or ""
        if server ~= "*" then
          desc = desc .. " (" .. server .. ")"
        end
        add_row(k.mode, show(raw), desc, origin)
        rows[show(raw) .. "\0\0" .. origin].domain = "code/LSP"
      end
    end
  end
end

--- Raccourcis posés par filetype (buffer-local) : on ouvre un buffer par filetype.
local FILETYPES = {
  "php", "twig", "javascript", "typescript", "vue", "json", "yaml", "markdown", "sql",
  "dockerfile", "kotlin", "java", "terraform", "gitcommit", "xml", "lua",
}

local function collect_filetypes(done)
  -- verbose=1 bloque certains FileType (gitcommit) en headless : on le coupe ici ;
  -- l'origine vient alors de la callback ou de l'index des sources.
  vim.o.verbose = 0
  local i = 0
  local function next_ft()
    i = i + 1
    local ft = FILETYPES[i]
    if not ft then
      return done()
    end
    local buf = vim.api.nvim_create_buf(true, false)
    vim.api.nvim_set_current_buf(buf)
    vim.bo[buf].filetype = ft
    vim.defer_fn(function()
      local ok, err = pcall(function()
      for _, mode in ipairs(MODES) do
        for _, map in ipairs(vim.api.nvim_buf_get_keymap(buf, mode)) do
          if not skip(map) then
            local file = set_from(mode, map, true)
            if map.callback and not (file and under_config(file)) then
              local src = debug.getinfo(map.callback, "S").source:gsub("^@", "")
              if under_config(src) then
                file = src
              end
            end
            if not is_runtime(file) then
              local origin
              if file and under_config(file) then
                origin = "perso"
              elseif file and file:find("/LazyVim/", 1, true) then
                origin = lazyvim_origin(file)
              elseif perso_index_loose[map.lhsraw] then
                origin = "perso"
              else
                origin = lazyvim_from_index(map.lhsraw)
                  or (file and file:match("/lazy/([^/]+)/") and ("plugin " .. file:match("/lazy/([^/]+)/")))
                  or "autres"
              end
              add_row(mode, show(map.lhsraw), map.desc, origin, ft)
            end
          end
        end
      end
      end)
      if not ok then
        io.stdout:write("inventaire [" .. ft .. "] : " .. tostring(err) .. "\n")
      end
      pcall(vim.api.nvim_buf_delete, buf, { force = true })
      next_ft()
    end, 150)
  end
  next_ft()
end

-- ─── Plugins ───────────────────────────────────────────────────────────────

local function plugin_rows()
  local perso_specs = {}
  for _, d in ipairs(config_dirs) do
    if d then
      for _, f in ipairs(lua_files(d .. "/lua/plugins")) do
        perso_specs[#perso_specs + 1] = read(f)
      end
      break
    end
  end
  local perso_text = table.concat(perso_specs, "\n")

  local extras = vim.json.decode(read(vim.fn.stdpath("config") .. "/lazyvim.json")).extras or {}
  local extra_text = {}
  for _, mod in ipairs(extras) do
    local path = lazy_root .. "/LazyVim/lua/" .. mod:gsub("%.", "/") .. ".lua"
    extra_text[#extra_text + 1] = { name = mod:gsub("^lazyvim%.plugins%.extras%.", ""), text = read(path) }
  end

  local list = {}
  for name, plugin in pairs(require("lazy.core.config").plugins) do
    local url = plugin.url or ""
    local repo = url:match("github%.com/([^/]+/[^/%.]+)") or plugin[1] or name
    local origin
    local needle = '"' .. repo .. '"'
    if perso_text:find(needle, 1, true) or perso_text:find("'" .. repo .. "'", 1, true) then
      origin = "perso"
    else
      for _, e in ipairs(extra_text) do
        if e.text:find(needle, 1, true) then
          origin = "LazyVim (extra " .. e.name .. ")"
          break
        end
      end
      origin = origin or "LazyVim (cœur)"
    end
    local role = ""
    local ok, desc = pcall(function()
      return vim.trim((read(plugin.dir .. "/README.md"):match("\n%s*([^#\n!<%[][^\n]+)") or ""))
    end)
    if ok and desc then
      role = desc:sub(1, 90):gsub("|", "\\|")
    end
    list[#list + 1] = { name = name, origin = origin, role = role }
  end
  table.sort(list, function(a, b)
    if a.origin ~= b.origin then
      return a.origin == "perso"
    end
    return a.name:lower() < b.name:lower()
  end)
  return list
end

-- ─── Écriture ──────────────────────────────────────────────────────────────

local function write()
  local lines = {
    "# Tri de l'ancienne config LazyVim",
    "",
    "Généré par `tools/inventaire.lua`. Cocher `[x]` ce qui doit être repris dans neovimanu.",
    "Les lignes « perso » sont pré-cochées. Doublons natifs de Neovim 0.12 : `gr`↔`grr`,",
    "`<leader>ca`↔`gra`, `<leader>cr`↔`grn`, `gI`↔`gri` — les cocher les ajoute en alias,",
    "ne pas les cocher garde seulement la touche native.",
    "",
  }
  local by_domain = {}
  for _, key in ipairs(order) do
    local r = rows[key]
    by_domain[r.domain] = by_domain[r.domain] or {}
    table.insert(by_domain[r.domain], r)
  end
  for _, domain in ipairs(DOMAINS) do
    local list = by_domain[domain]
    if list then
      table.sort(list, function(a, b)
        if a.lhs ~= b.lhs then
          return a.lhs < b.lhs
        end
        return a.desc < b.desc
      end)
      vim.list_extend(lines, {
        "## Raccourcis — " .. domain,
        "| ✔ | Mode | Touche | Description | Origine |",
        "|---|------|--------|-------------|---------|",
      })
      for _, r in ipairs(list) do
        local lhs = r.lhs:gsub("|", "<Bar>")
        lines[#lines + 1] = string.format(
          "| %s | %s | `%s` | %s | %s |",
          r.origin == "perso" and "[x]" or "[ ]",
          r.mode,
          lhs,
          r.desc,
          r.origin
        )
      end
      lines[#lines + 1] = ""
    end
  end
  vim.list_extend(lines, {
    "## Plugins",
    "| ✔ | Plugin | Origine | Rôle |",
    "|---|--------|---------|------|",
  })
  for _, p in ipairs(plugin_rows()) do
    lines[#lines + 1] =
      string.format("| %s | %s | %s | %s |", p.origin == "perso" and "[x]" or "[ ]", p.name, p.origin, p.role)
  end
  vim.fn.mkdir(vim.fs.dirname(out_path), "p")
  vim.fn.writefile(lines, out_path)
  io.stdout:write("écrit : " .. out_path .. " (" .. #order .. " raccourcis)\n")
end

-- ─── Déroulé ───────────────────────────────────────────────────────────────

vim.api.nvim_exec_autocmds("User", { pattern = "VeryLazy" })
vim.defer_fn(function()
  local ok, err = pcall(function()
    collect_globals()
    collect_lsp()
  end)
  if not ok then
    io.stderr:write("inventaire : " .. tostring(err) .. "\n")
    return vim.cmd("cquit 1")
  end
  collect_filetypes(function()
    local ok2, err2 = pcall(write)
    if not ok2 then
      io.stderr:write("inventaire : " .. tostring(err2) .. "\n")
      return vim.cmd("cquit 1")
    end
    vim.cmd("qa!")
  end)
end, 1500)
