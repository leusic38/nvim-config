-- Web : JavaScript, TypeScript, JSX/TSX, Vue, CSS/SCSS, HTML (modèle de lang/lua.lua).
-- Un seul fichier : ces langages partagent serveurs, formateur et outils.
--
-- vtsls : serveur TypeScript/JavaScript (commandes « source definition », références du
-- fichier, imports…). Les serveurs restent sur l'hôte et lisent node_modules du projet.
-- Raccourcis propres à vtsls, posés à son attache (après ceux de lsp.lua : son `gD`, la
-- définition « source », remplace « déclaration »).

local project = require("manu.project")

local M = {}

require("manu.mason").ensure({ "vtsls" })

-- Indices inline (perso) : noms de paramètres pour les littéraux en TS, partout en JS.
local function inlay_hints(parameter_names)
  return {
    parameterNames = { enabled = parameter_names, suppressWhenArgumentMatchesName = true },
    parameterTypes = { enabled = true },
    variableTypes = { enabled = false },
    propertyDeclarationTypes = { enabled = true },
    functionLikeReturnTypes = { enabled = true },
    enumMemberValues = { enabled = true },
  }
end

local TS_FILETYPES = {
  "javascript", "javascriptreact", "javascript.jsx",
  "typescript", "typescriptreact", "typescript.tsx",
}

-- Réglages de l'extra LazyVim lang.typescript + indices perso de l'ancien javascript.lua.
vim.lsp.config("vtsls", {
  filetypes = TS_FILETYPES,
  settings = {
    complete_function_calls = true,
    vtsls = {
      enableMoveToFileCodeAction = true,
      autoUseWorkspaceTsdk = true,
      experimental = {
        maxInlayHintLength = 30,
        completion = { enableServerSideFuzzyMatch = true },
      },
    },
    typescript = {
      updateImportsOnFileMove = { enabled = "always" },
      suggest = { completeFunctionCalls = true },
      inlayHints = inlay_hints("literals"),
    },
    javascript = {
      updateImportsOnFileMove = { enabled = "always" },
      suggest = { completeFunctionCalls = true },
      inlayHints = inlay_hints("all"),
    },
  },
})
vim.lsp.enable({ "vtsls" })

require("manu.treesitter").install({ "javascript", "typescript", "tsx", "jsdoc", "css", "scss", "html", "vue" })

-- ─── Commandes vtsls (remplacent LazyVim.lsp.execute / LazyVim.lsp.action) ──

--- Action « source » appliquée directement (organiser les imports, imports manquants…).
local function source_action(kind)
  return function()
    vim.lsp.buf.code_action({ apply = true, context = { only = { kind }, diagnostics = {} } })
  end
end

local function vtsls_client(bufnr)
  return vim.lsp.get_clients({ bufnr = bufnr or 0, name = "vtsls" })[1]
end

--- Commande vtsls dont le résultat est une liste d'emplacements : saut direct s'il n'y en a
--- qu'un, sinon liste fzf.
local function exec_locations(command, arguments)
  local client = vtsls_client()
  if not client then
    return
  end
  client:exec_cmd({ title = command, command = command, arguments = arguments }, { bufnr = 0 }, function(err, result)
    if err then
      return vim.notify(command .. " : " .. (err.message or vim.inspect(err)), vim.log.levels.ERROR)
    end
    if not result or vim.tbl_isempty(result) then
      return vim.notify("Aucun résultat", vim.log.levels.INFO)
    end
    if #result == 1 then
      return vim.lsp.util.show_document(result[1], client.offset_encoding, { focus = true })
    end
    vim.fn.setqflist({}, " ", { title = command, items = vim.lsp.util.locations_to_items(result, client.offset_encoding) })
    require("fzf-lua").quickfix()
  end)
end

local function goto_source_definition()
  local params = vim.lsp.util.make_position_params(0, "utf-16")
  exec_locations("typescript.goToSourceDefinition", { params.textDocument.uri, params.position })
end

local function file_references()
  exec_locations("typescript.findAllFileReferences", { vim.uri_from_bufnr(0) })
end

vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("manu_vtsls_attach", { clear = true }),
  callback = function(ev)
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    if not client or client.name ~= "vtsls" then
      return
    end
    local function bmap(lhs, rhs, desc)
      vim.keymap.set("n", lhs, rhs, { buffer = ev.buf, desc = desc })
    end
    -- Touches LazyVim (extra lang.typescript).
    bmap("gD", goto_source_definition, "Aller à la définition source (TS)")
    bmap("gR", file_references, "Références du fichier (TS)")
    bmap("<leader>cM", source_action("source.addMissingImports.ts"), "Ajouter les imports manquants")
    bmap("<leader>cD", source_action("source.fixAll.ts"), "Corriger tous les diagnostics (TS)")
    bmap("<leader>cV", function()
      client:exec_cmd({ title = "Version TS", command = "typescript.selectTypeScriptVersion" }, { bufnr = ev.buf })
    end, "Choisir la version TypeScript du projet")
    -- Perso (ancien javascript.lua).
    bmap("<leader>jlo", source_action("source.organizeImports"), "JS : organiser les imports")
    bmap("<leader>jls", source_action("source.sortImports"), "JS : trier les imports")
    bmap("<leader>jlu", source_action("source.removeUnused.ts"), "JS : retirer les imports inutilisés")
    bmap("<leader>jlg", goto_source_definition, "JS : aller à la définition source")
    bmap("<leader>jla", source_action("source.addMissingImports.ts"), "JS : ajouter les imports manquants")
    bmap("<leader>jlr", function()
      -- Même action que <leader>cR (lsp.lua) : renommer le fichier en prévenant le serveur.
      vim.api.nvim_feedkeys(vim.keycode("<leader>cR"), "m", false)
    end, "JS : renommer le fichier")
  end,
})

project.report("web : serveur", function(bufnr)
  if not vim.tbl_contains(TS_FILETYPES, vim.bo[bufnr].filetype) and vim.bo[bufnr].filetype ~= "vue" then
    return nil
  end
  local names = vim.tbl_map(function(c)
    return c.name
  end, vim.lsp.get_clients({ bufnr = bufnr }))
  return #names > 0 and (table.concat(names, ", ") .. " (hôte)") or "aucun serveur attaché"
end)

return M
