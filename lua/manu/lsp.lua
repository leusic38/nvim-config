-- LSP natif de Neovim 0.12 (vim.lsp.config / vim.lsp.enable).
--
-- nvim-lspconfig : fournit seulement les configs de serveurs (dossier lsp/*.lua) ;
--   chaque fichier lang/<langage>.lua active ses serveurs avec vim.lsp.enable().
-- Mason (manu.mason) installe les serveurs ; son dossier bin est ajouté au PATH.
--
-- Raccourcis : ceux de Neovim (grn, gra, grr, gri, grt, gO, K, <C-s> en insertion) restent ;
-- s'y ajoutent les touches LazyVim retenues au tri, posées par buffer dans LspAttach.

vim.pack.add({ "https://github.com/neovim/nvim-lspconfig" }, { confirm = false })

local map = vim.keymap.set

-- ─── Outils ────────────────────────────────────────────────────────────────

--- Saute à la référence suivante/précédente du symbole sous le curseur (documentHighlight).
---@param dir 1|-1
local function jump_reference(dir)
  local win = vim.api.nvim_get_current_win()
  local buf = vim.api.nvim_get_current_buf()
  local cursor = vim.api.nvim_win_get_cursor(win)
  vim.lsp.buf_request_all(buf, "textDocument/documentHighlight", function(client)
    return vim.lsp.util.make_position_params(win, client.offset_encoding)
  end, function(results)
    local positions = {}
    for client_id, res in pairs(results) do
      local client = vim.lsp.get_client_by_id(client_id)
      for _, h in ipairs(res.result or {}) do
        local row = h.range.start.line
        local line = vim.api.nvim_buf_get_lines(buf, row, row + 1, false)[1] or ""
        local col = vim.str_byteindex(line, client and client.offset_encoding or "utf-16", h.range.start.character, false)
        table.insert(positions, { row + 1, col })
      end
    end
    table.sort(positions, function(a, b)
      return a[1] < b[1] or (a[1] == b[1] and a[2] < b[2])
    end)
    if #positions == 0 then
      return
    end
    local target
    if dir > 0 then
      for _, p in ipairs(positions) do
        if p[1] > cursor[1] or (p[1] == cursor[1] and p[2] > cursor[2]) then
          target = p
          break
        end
      end
      target = target or positions[1]
    else
      for i = #positions, 1, -1 do
        local p = positions[i]
        if p[1] < cursor[1] or (p[1] == cursor[1] and p[2] < cursor[2]) then
          target = p
          break
        end
      end
      target = target or positions[#positions]
    end
    if vim.api.nvim_win_is_valid(win) then
      vim.api.nvim_win_set_cursor(win, target)
    end
  end)
end

--- Renomme le fichier courant en prévenant les serveurs (workspace/willRenameFiles).
local function rename_file()
  local buf = vim.api.nvim_get_current_buf()
  local old = vim.api.nvim_buf_get_name(buf)
  if old == "" then
    return vim.notify("Buffer sans fichier", vim.log.levels.WARN)
  end
  vim.ui.input({ prompt = "Nouveau nom : ", default = old, completion = "file" }, function(new)
    if not new or new == "" or new == old then
      return
    end
    new = vim.fn.fnamemodify(new, ":p")
    local params = { files = { { oldUri = vim.uri_from_fname(old), newUri = vim.uri_from_fname(new) } } }
    local clients = vim.lsp.get_clients({ bufnr = buf })
    for _, client in ipairs(clients) do
      if client:supports_method("workspace/willRenameFiles") then
        local resp = client:request_sync("workspace/willRenameFiles", params, 2000, buf)
        if resp and resp.result then
          vim.lsp.util.apply_workspace_edit(resp.result, client.offset_encoding)
        end
      end
    end
    vim.cmd("silent! write")
    vim.fn.mkdir(vim.fn.fnamemodify(new, ":h"), "p")
    if vim.fn.rename(old, new) ~= 0 then
      return vim.notify("Renommage impossible : " .. new, vim.log.levels.ERROR)
    end
    vim.cmd.edit(vim.fn.fnameescape(new))
    vim.api.nvim_buf_delete(buf, { force = true })
    for _, client in ipairs(clients) do
      if client:supports_method("workspace/didRenameFiles") then
        client:notify("workspace/didRenameFiles", params)
      end
    end
  end)
end

--- Saut LSP sans doublons : plusieurs serveurs sur un même buffer (Intelephense et
--- symfony-lsp en PHP) renvoient souvent le même emplacement ; Neovim ouvrirait alors une
--- quickfix au lieu de sauter. Un seul emplacement distinct (du projet courant de
--- préférence) → saut direct, sinon liste fzf.
---@param fn fun(opts: vim.lsp.ListOpts)
local function goto_unique(fn)
  return function()
    fn({
      on_list = function(list)
        local seen, items = {}, {}
        for _, it in ipairs(list.items or {}) do
          local key = ("%s:%d"):format(it.filename, it.lnum)
          if not seen[key] then
            seen[key] = true
            table.insert(items, it)
          end
        end
        if #items == 0 then
          return vim.notify("Aucun résultat", vim.log.levels.INFO)
        end
        -- Plusieurs copies d'une même classe (lama/vendor et lama/mcp/vendor) : garder
        -- celles du projet du fichier courant (composer.json / package.json le plus proche).
        if #items > 1 then
          local markers = { "composer.json", "package.json" }
          -- Projet d'un fichier : on coupe à vendor/ ou node_modules/ (chaque paquet y a son
          -- propre composer.json / package.json) avant de chercher le marqueur.
          local function project_of(path)
            path = path:gsub("/vendor/.*$", "/x"):gsub("/node_modules/.*$", "/x")
            return vim.fs.root(path, markers)
          end
          local here = project_of(vim.api.nvim_buf_get_name(0))
          local same = vim.tbl_filter(function(it)
            return here ~= nil and project_of(it.filename) == here
          end, items)
          if #same > 0 then
            items = same
          end
          -- Encore plusieurs : préférer le code du projet et son vendor/ racine à un vendor/
          -- imbriqué plus bas (sous-dossier sans composer.json propre).
          if #items > 1 and here then
            local top = vim.tbl_filter(function(it)
              local before = it.filename:match("^(.-)/vendor/") or it.filename:match("^(.-)/node_modules/")
              return before == nil or before == here
            end, items)
            if #top > 0 then
              items = top
            end
          end
        end
        if #items == 1 then
          local it = items[1]
          vim.cmd("normal! m'") -- retour possible avec <C-o>
          if vim.fs.normalize(it.filename) ~= vim.fs.normalize(vim.api.nvim_buf_get_name(0)) then
            vim.cmd.edit(vim.fn.fnameescape(it.filename))
          end
          vim.api.nvim_win_set_cursor(0, { it.lnum, math.max((it.col or 1) - 1, 0) })
          vim.cmd("normal! zv")
          return
        end
        vim.fn.setqflist({}, " ", { title = list.title, items = items })
        require("fzf-lua").quickfix()
      end,
    })
  end
end

local function code_action_only(kind)
  return function()
    vim.lsp.buf.code_action({ context = { only = { kind }, diagnostics = {} }, apply = kind == "source.organizeImports" })
  end
end

-- ─── Raccourcis par buffer (LspAttach) ─────────────────────────────────────

vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("manu_lsp_attach", { clear = true }),
  callback = function(ev)
    local buf = ev.buf
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    local function bmap(mode, lhs, rhs, desc, method)
      if method and client and not client:supports_method(method, buf) then
        return
      end
      map(mode, lhs, rhs, { buffer = buf, desc = desc })
    end

    -- gd : laissé au buffer s'il en a déjà un (ex. symfony-goto, Plan 2).
    local has_gd = vim.iter(vim.api.nvim_buf_get_keymap(buf, "n")):any(function(m)
      return m.lhs == "gd"
    end)
    if not has_gd then
      bmap("n", "gd", goto_unique(vim.lsp.buf.definition), "Aller à la définition", "textDocument/definition")
    end
    bmap("n", "gr", vim.lsp.buf.references, "Références")
    bmap("n", "gI", goto_unique(vim.lsp.buf.implementation), "Aller à l'implémentation")
    bmap("n", "gy", goto_unique(vim.lsp.buf.type_definition), "Aller au type")
    bmap("n", "gD", goto_unique(vim.lsp.buf.declaration), "Aller à la déclaration")
    bmap("n", "K", function()
      vim.lsp.buf.hover()
    end, "Documentation (survol)")
    bmap("n", "gK", vim.lsp.buf.signature_help, "Signature", "textDocument/signatureHelp")
    bmap("i", "<C-k>", vim.lsp.buf.signature_help, "Signature", "textDocument/signatureHelp")
    bmap({ "n", "x" }, "<leader>ca", vim.lsp.buf.code_action, "Actions de code")
    bmap("n", "<leader>cA", code_action_only("source"), "Actions sur le fichier (source)")
    bmap("n", "<leader>co", code_action_only("source.organizeImports"), "Organiser les imports")
    bmap("n", "<leader>cr", vim.lsp.buf.rename, "Renommer le symbole")
    bmap("n", "<leader>cR", rename_file, "Renommer le fichier")
    bmap({ "n", "x" }, "<leader>cc", vim.lsp.codelens.run, "Lancer le codelens")
    bmap("n", "<leader>cC", function()
      vim.lsp.codelens.enable(true, { bufnr = buf })
    end, "Afficher les codelens")
    bmap("n", "<leader>cl", "<cmd>checkhealth vim.lsp<cr>", "Infos LSP")
    for _, k in ipairs({ { "]]", 1 }, { "<M-n>", 1 }, { "[[", -1 }, { "<M-p>", -1 } }) do
      bmap("n", k[1], function()
        jump_reference(k[2])
      end, k[2] > 0 and "Référence suivante" or "Référence précédente", "textDocument/documentHighlight")
    end

    if client and client:supports_method("textDocument/inlayHint", buf) then
      vim.lsp.inlay_hint.enable(true, { bufnr = buf })
    end
  end,
})

-- ─── Raccourcis globaux : diagnostics, listes ──────────────────────────────

local function diagnostic_goto(count, severity)
  return function()
    vim.diagnostic.jump({
      count = count * vim.v.count1,
      severity = severity and vim.diagnostic.severity[severity] or nil,
      float = true,
    })
  end
end

-- Callbacks enveloppés : l'origine d'un raccourci est le fichier de sa fonction (test keymaps).
map("n", "<leader>cd", function()
  vim.diagnostic.open_float()
end, { desc = "Diagnostics de la ligne" })
map("n", "]d", diagnostic_goto(1), { desc = "Diagnostic suivant" })
map("n", "[d", diagnostic_goto(-1), { desc = "Diagnostic précédent" })
map("n", "]e", diagnostic_goto(1, "ERROR"), { desc = "Erreur suivante" })
map("n", "[e", diagnostic_goto(-1, "ERROR"), { desc = "Erreur précédente" })
map("n", "]w", diagnostic_goto(1, "WARN"), { desc = "Avertissement suivant" })
map("n", "[w", diagnostic_goto(-1, "WARN"), { desc = "Avertissement précédent" })

map("n", "<leader>xl", function()
  local ok, err = pcall(vim.fn.getloclist(0, { winid = 0 }).winid ~= 0 and vim.cmd.lclose or vim.cmd.lopen)
  if not ok and err then
    vim.notify(err, vim.log.levels.ERROR)
  end
end, { desc = "Liste locale (ouvrir/fermer)" })
map("n", "<leader>xq", function()
  local ok, err = pcall(vim.fn.getqflist({ winid = 0 }).winid ~= 0 and vim.cmd.cclose or vim.cmd.copen)
  if not ok and err then
    vim.notify(err, vim.log.levels.ERROR)
  end
end, { desc = "Quickfix (ouvrir/fermer)" })

map("n", "<leader>cm", "<cmd>Mason<cr>", { desc = "Mason" })
map("n", "<leader>uh", function()
  local on = not vim.lsp.inlay_hint.is_enabled({ bufnr = 0 })
  vim.lsp.inlay_hint.enable(on, { bufnr = 0 })
  vim.notify((on and "Activé" or "Désactivé") .. " : indices inline (inlay hints)")
end, { desc = "Basculer les indices inline (inlay hints)" })
