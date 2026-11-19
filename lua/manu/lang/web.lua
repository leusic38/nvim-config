-- Web : JavaScript, TypeScript, JSX/TSX, Vue, CSS/SCSS, HTML (modèle de lang/lua.lua).
-- Un seul fichier : ces langages partagent serveurs, formateur et outils.
--
-- vtsls  : serveur TypeScript/JavaScript (commandes « source definition », références du
--          fichier, imports…), aussi pour le <script> des .vue (plugin @vue/typescript-plugin).
-- vue_ls : serveur Vue (templates, styles), en mode hybride : il délègue le TypeScript à vtsls.
-- ESLint : serveur eslint-lsp ; corrections appliquées à l'enregistrement, sauf si le
--          formatage est coupé (<leader>uf / <leader>uF).
-- cssls / html : serveurs CSS/SCSS/LESS et HTML.
-- Prettier : seulement si le projet a une config Prettier (règle du formatage) ; celui du
--          projet (node_modules/.bin), dans le conteneur Node s'il y en a un, sinon Mason.
-- Les serveurs restent sur l'hôte et lisent node_modules du projet.
-- Raccourcis propres à vtsls, posés à son attache (après ceux de lsp.lua : son `gD`, la
-- définition « source », remplace « déclaration »).

local project = require("manu.project")

local M = {}

require("manu.mason").ensure({ "vtsls", "vue-language-server", "eslint-lsp", "css-lsp", "html-lsp", "prettier" })

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
  "vue",
}

-- Plugin TypeScript de Vue, livré avec le paquet Mason vue-language-server.
local VUE_TS_PLUGIN = vim.fn.stdpath("data") .. "/mason/packages/vue-language-server/node_modules/@vue/language-server"

-- Réglages de l'extra LazyVim lang.typescript + indices perso de l'ancien javascript.lua.
vim.lsp.config("vtsls", {
  filetypes = TS_FILETYPES,
  settings = {
    complete_function_calls = true,
    vtsls = {
      tsserver = {
        globalPlugins = {
          {
            name = "@vue/typescript-plugin",
            location = VUE_TS_PLUGIN,
            languages = { "vue" },
            configNamespace = "typescript",
            enableForWorkspaceTypeScriptVersions = true,
          },
        },
      },
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
vim.lsp.config("eslint", {
  settings = { workingDirectory = { mode = "auto" }, format = true },
})
vim.lsp.enable({ "vtsls", "vue_ls", "eslint", "cssls", "html" })

-- ─── Prettier, seulement si le projet l'a configuré ────────────────────────

local PRETTIER_CONFIGS = {
  ".prettierrc", ".prettierrc.json", ".prettierrc.yml", ".prettierrc.yaml", ".prettierrc.json5",
  ".prettierrc.js", ".prettierrc.cjs", ".prettierrc.mjs", ".prettierrc.ts", ".prettierrc.toml",
  "prettier.config.js", "prettier.config.cjs", "prettier.config.mjs", "prettier.config.ts",
}

--- Le projet (en remontant depuis dir) a-t-il une config Prettier ? Fichier dédié, ou clé
--- « prettier » du package.json.
function M.has_prettier_config(dir)
  if vim.fs.find(PRETTIER_CONFIGS, { path = dir, upward = true })[1] then
    return true
  end
  local package_json = vim.fs.find("package.json", { path = dir, upward = true })[1]
  if not package_json then
    return false
  end
  local ok, lines = pcall(vim.fn.readfile, package_json)
  local ok2, pkg = pcall(vim.json.decode, ok and table.concat(lines, "\n") or "")
  return ok2 and type(pkg) == "table" and pkg.prettier ~= nil
end

--- argv Prettier pour ce fichier (formatage par stdin), ou nil (conteneur arrêté).
local function prettier_argv(ctx, extra)
  local root = vim.fs.root(ctx.dirname, { "package.json" }) or ctx.dirname
  local argv = project.tool(root, "prettier", function(path)
    local args = { "--stdin-filepath", path(ctx.filename) }
    if vim.bo[ctx.buf].filetype:match("^yaml") then
      -- YAML : toujours 2 espaces, même si le .prettierrc dit autre chose (pendant du
      -- forçage .editorconfig du socle) ; le reste du .prettierrc s'applique.
      vim.list_extend(args, { "--config-precedence", "cli-override", "--tab-width", "2", "--use-tabs", "false" })
    else
      vim.list_extend(args, { "--config-precedence", "prefer-file" })
    end
    return vim.list_extend(args, extra or {})
  end, { runtime = "node", host_if_missing = true })
  return argv, root
end

require("conform").formatters.prettier_project = {
  condition = function(_, ctx)
    return M.has_prettier_config(ctx.dirname) and prettier_argv(ctx) ~= nil
  end,
  command = function(_, ctx)
    return (prettier_argv(ctx) or { "false" })[1]
  end,
  args = function(_, ctx)
    return vim.list_slice(prettier_argv(ctx) or {}, 2)
  end,
  range_args = function(_, ctx)
    return vim.list_slice(prettier_argv(ctx, { "--range-start", "$RANGE_START", "--range-end", "$RANGE_END" }) or {}, 2)
  end,
  cwd = function(_, ctx)
    return select(2, prettier_argv(ctx))
  end,
  stdin = true,
}
for _, ft in ipairs({ "javascript", "typescript", "javascriptreact", "typescriptreact", "vue", "css", "scss", "less", "html" }) do
  -- Jamais de formatage par le LSP (vtsls/vue_ls imposeraient leur style).
  require("conform").formatters_by_ft[ft] = { "prettier_project", lsp_format = "never" }
end

-- ─── ESLint : corrections à l'enregistrement ───────────────────────────────

--- Applique toutes les corrections ESLint du buffer (synchrone, 1 s max).
function M.eslint_fix(bufnr)
  bufnr = bufnr == 0 and vim.api.nvim_get_current_buf() or bufnr
  local client = vim.lsp.get_clients({ bufnr = bufnr, name = "eslint" })[1]
  if not client then
    return false
  end
  client:request_sync("workspace/executeCommand", {
    command = "eslint.applyAllFixes",
    arguments = { { uri = vim.uri_from_bufnr(bufnr), version = vim.lsp.util.buf_versions[bufnr] } },
  }, 1000, bufnr)
  return true
end

vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("manu_eslint_attach", { clear = true }),
  callback = function(ev)
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    if not client or client.name ~= "eslint" then
      return
    end
    vim.api.nvim_create_autocmd("BufWritePre", {
      group = vim.api.nvim_create_augroup("manu_eslint_fix_" .. ev.buf, { clear = true }),
      buffer = ev.buf,
      callback = function(w)
        if require("manu.format").enabled(w.buf) then
          M.eslint_fix(w.buf)
        end
      end,
    })
  end,
})

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

-- ─── Tests : Jest et Vitest (neotest) ──────────────────────────────────────
-- Outil du projet (node_modules/.bin), dans le conteneur Node s'il y en a un (lama :
-- conteneur php avec Node via nvm), via bin/docker-test qui traduit les chemins et rapatrie
-- le rapport JSON.

vim.pack.add({
  "https://github.com/nvim-neotest/neotest-jest",
  "https://github.com/marilari88/neotest-vitest",
}, { confirm = false })

local config_dir = vim.fn.stdpath("config")

--- Commande de test (chaîne : les adaptateurs la découpent sur les espaces).
---@param tool "jest"|"vitest"
function M.test_command(tool, path)
  local root = vim.fs.root(path or vim.api.nvim_buf_get_name(0), { "package.json" }) or assert(vim.uv.cwd())
  local rel = project.node_bin(root, tool) or ("node_modules/.bin/" .. tool)
  local docker = project.docker(root, "node")
  if not docker then
    return root .. "/" .. rel
  end
  -- Conteneur arrêté : échec explicite (le message de project.cmd dit comment le démarrer).
  if not project.cmd(root, {}, "node") then
    return "false"
  end
  return table.concat({
    config_dir .. "/bin/docker-test", root, docker.service, docker.container_root, docker.setup and "nvm" or "-", rel,
  }, " ")
end

local function package_root(path)
  return vim.fs.root(path, { "package.json" }) or assert(vim.uv.cwd())
end

local test = require("manu.test")
test.add_adapter(require("neotest-jest")({
  jestCommand = function(path)
    return M.test_command("jest", path)
  end,
  jestConfigFile = function(path)
    local found = vim.fs.find({ "jest.config.js", "jest.config.ts", "jest.config.mjs", "jest.config.cjs" }, {
      path = vim.fs.dirname(path),
      upward = true,
    })[1]
    return found or (package_root(path) .. "/jest.config.js")
  end,
  env = { CI = "true" },
  cwd = function(path)
    return package_root(path)
  end,
}))
test.add_adapter(require("neotest-vitest")({
  vitestCommand = function(path)
    return M.test_command("vitest", path)
  end,
  filter_dir = function(name)
    return name ~= "node_modules"
  end,
  cwd = function(path)
    return package_root(path)
  end,
}))

-- ─── Débogage Node (js-debug-adapter, sur l'hôte) ──────────────────────────

require("manu.mason").ensure({ "js-debug-adapter" })
local debug = require("manu.debug")
local js_debug = vim.fn.stdpath("data") .. "/mason/packages/js-debug-adapter/js-debug/src/dapDebugServer.js"
for _, adapter in ipairs({ "pwa-node", "pwa-chrome", "pwa-msedge", "node-terminal", "pwa-extensionHost" }) do
  debug.adapter(adapter, {
    type = "server",
    host = "localhost",
    port = "${port}",
    executable = { command = "node", args = { js_debug, "${port}" } },
  })
end
local node_configs = function()
  return {
    {
      type = "pwa-node", request = "launch", name = "Launch Node.js Program",
      program = "${file}", cwd = "${workspaceFolder}", sourceMaps = true, skipFiles = { "<node_internals>/**" },
    },
    {
      type = "pwa-node", request = "attach", name = "Attach to Node.js Process",
      processId = require("dap.utils").pick_process, cwd = "${workspaceFolder}", sourceMaps = true,
      skipFiles = { "<node_internals>/**" },
    },
    {
      type = "pwa-node", request = "launch", name = "Debug Jest Tests", runtimeExecutable = "node",
      runtimeArgs = { "./node_modules/jest/bin/jest.js", "--runInBand" }, rootPath = "${workspaceFolder}",
      cwd = "${workspaceFolder}", console = "integratedTerminal", internalConsoleOptions = "neverOpen",
      skipFiles = { "<node_internals>/**" },
    },
  }
end
for _, ft in ipairs({ "javascript", "typescript", "vue" }) do
  debug.defaults(ft, node_configs)
end

-- ─── package.json : package-info ───────────────────────────────────────────
-- package-info.nvim : versions installées / dernières affichées dans package.json, mise à
-- jour ou suppression d'un paquet sans quitter l'éditeur. nui.nvim : ses fenêtres.

vim.pack.add({
  "https://github.com/MunifTanjim/nui.nvim",
  "https://github.com/vuki656/package-info.nvim",
}, { confirm = false })
require("package-info").setup({
  highlights = { up_to_date = { fg = "#3C4048" }, outdated = { fg = "#d19a66" } },
  icons = { enable = true, style = { up_to_date = "|  ", outdated = "|  " } },
  autostart = true,
  hide_up_to_date = false,
  hide_unstable_versions = false,
})

vim.api.nvim_create_autocmd("BufEnter", {
  group = vim.api.nvim_create_augroup("manu_package_info", { clear = true }),
  pattern = "package.json",
  callback = function(ev)
    local pi = require("package-info")
    local function bmap(lhs, fn, desc)
      vim.keymap.set("n", lhs, fn, { buffer = ev.buf, desc = desc })
    end
    bmap("<leader>jps", pi.show, "JS : afficher les versions")
    bmap("<leader>jpc", pi.hide, "JS : masquer les versions")
    bmap("<leader>jpt", pi.toggle, "JS : basculer les versions")
    bmap("<leader>jpu", pi.update, "JS : mettre à jour le paquet")
    bmap("<leader>jpd", pi.delete, "JS : supprimer le paquet")
    bmap("<leader>jpi", pi.install, "JS : installer un paquet")
    bmap("<leader>jpv", pi.change_version, "JS : changer la version du paquet")
  end,
})

-- ─── npm / yarn : terminal flottant, dans le conteneur Node s'il y en a un ──

--- Lance argv à la racine du package.json, dans le conteneur Node du projet s'il y en a un.
function M.run(bufnr, argv)
  local root = vim.fs.root(bufnr, { "package.json" })
  if not root then
    return vim.notify("Pas de package.json au-dessus de ce fichier.", vim.log.levels.WARN)
  end
  local cmd, err = project.cmd(root, argv, "node")
  if not cmd then
    return vim.notify(err, vim.log.levels.WARN)
  end
  return require("manu.terminal").run(cmd, { cwd = root, title = table.concat(argv, " ") })
end

local function ask_run(bufnr, tool)
  vim.ui.input({ prompt = tool .. " run " }, function(script)
    if script and vim.trim(script) ~= "" then
      M.run(bufnr, vim.list_extend({ tool, "run" }, vim.split(vim.trim(script), "%s+")))
    end
  end)
end

-- ─── Raccourcis JS / TS / Vue (buffer, perso) ──────────────────────────────

vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("manu_web_keymaps", { clear = true }),
  pattern = TS_FILETYPES,
  callback = function(ev)
    local function bmap(lhs, rhs, desc)
      vim.keymap.set("n", lhs, rhs, { buffer = ev.buf, desc = desc })
    end
    local function neotest()
      return require("neotest")
    end
    local function dap()
      return require("dap")
    end
    -- Tests
    bmap("<leader>jta", function()
      neotest().run.run(vim.fn.expand("%"))
    end, "JS : tests du fichier")
    bmap("<leader>jtn", function()
      neotest().run.run()
    end, "JS : test au curseur")
    bmap("<leader>jts", function()
      neotest().summary.toggle()
    end, "JS : résumé des tests")
    bmap("<leader>jto", function()
      neotest().output.open({ enter = true })
    end, "JS : sortie du test")
    bmap("<leader>jtw", function()
      neotest().watch.toggle(vim.fn.expand("%"))
    end, "JS : surveiller les tests du fichier")
    -- Débogage
    bmap("<leader>jdb", function()
      require("persistent-breakpoints.api").toggle_breakpoint()
    end, "JS : point d'arrêt")
    bmap("<leader>jdc", function()
      dap().continue()
    end, "JS : continuer")
    bmap("<leader>jds", function()
      dap().step_over()
    end, "JS : pas suivant")
    bmap("<leader>jdi", function()
      dap().step_into()
    end, "JS : entrer")
    bmap("<leader>jdo", function()
      dap().step_out()
    end, "JS : sortir")
    bmap("<leader>jdr", function()
      dap().repl.open()
    end, "JS : REPL")
    bmap("<leader>jdl", function()
      dap().run_last()
    end, "JS : relancer la dernière session")
    -- npm / yarn (perso)
    local b = ev.buf
    bmap("<leader>jni", function()
      M.run(b, { "npm", "install" })
    end, "JS : npm install")
    bmap("<leader>jnr", function()
      ask_run(b, "npm")
    end, "JS : npm run …")
    bmap("<leader>jnt", function()
      M.run(b, { "npm", "test" })
    end, "JS : npm test")
    bmap("<leader>jnb", function()
      M.run(b, { "npm", "run", "build" })
    end, "JS : npm run build")
    bmap("<leader>jnd", function()
      M.run(b, { "npm", "run", "dev" })
    end, "JS : npm run dev")
    bmap("<leader>yi", function()
      M.run(b, { "yarn", "install" })
    end, "JS : yarn install")
    bmap("<leader>yr", function()
      ask_run(b, "yarn")
    end, "JS : yarn run …")
    bmap("<leader>yt", function()
      M.run(b, { "yarn", "test" })
    end, "JS : yarn test")
    bmap("<leader>yb", function()
      M.run(b, { "yarn", "build" })
    end, "JS : yarn build")
    bmap("<leader>yd", function()
      M.run(b, { "yarn", "dev" })
    end, "JS : yarn dev")
    -- Snippets perso (repris tels quels). <leader>jc attend timeoutlen avant de partir :
    -- c'est aussi le début de <leader>jcl/jce/jcw/jci.
    bmap("<leader>jc", "i// Component template<cr>export default {<cr>  name: '',<cr>  data() {<cr>    return {<cr>      <cr>    }<cr>  },<cr>  methods: {<cr>    <cr>  }<cr>}<esc>", "JS : modèle de composant")
    bmap("<leader>jf", "i// Function template<cr>const functionName = () => {<cr>  <cr>}<esc>", "JS : modèle de fonction")
    bmap("<leader>ja", "i// Async function template<cr>const asyncFunction = async () => {<cr>  try {<cr>    <cr>  } catch (error) {<cr>    console.error(error)<cr>  }<cr>}<esc>", "JS : modèle de fonction async")
    bmap("<leader>jtc", "i// TypeScript class template<cr>class ClassName {<cr>  private property: string;<cr><cr>  constructor(property: string) {<cr>    this.property = property;<cr>  }<cr><cr>  public method(): void {<cr>    <cr>  }<cr>}<esc>", "JS : modèle de classe TS")
    bmap("<leader>jti", "i// TypeScript interface template<cr>interface InterfaceName {<cr>  property: string;<cr>  method(): void;<cr>}<esc>", "JS : modèle d'interface TS")
    bmap("<leader>jcl", "iconsole.log()<esc>", "JS : console.log")
    bmap("<leader>jce", "iconsole.error()<esc>", "JS : console.error")
    bmap("<leader>jcw", "iconsole.warn()<esc>", "JS : console.warn")
    bmap("<leader>jci", "iconsole.info()<esc>", "JS : console.info")
    bmap("<leader>jle", function()
      if not M.eslint_fix(ev.buf) then
        vim.notify("ESLint n'est pas attaché à ce buffer (pas de config ESLint ?)", vim.log.levels.WARN)
      end
    end, "JS : corriger tous les problèmes ESLint")
    if vim.bo[ev.buf].filetype == "vue" then
      bmap("<leader>vc", vim.lsp.buf.code_action, "Vue : actions de code")
      bmap("<leader>vr", vim.lsp.buf.rename, "Vue : renommer")
      bmap("<leader>vs", "i<template><cr>  <div><cr>    <cr>  </div><cr></template><cr><cr><script><cr>export default {<cr>  name: 'ComponentName',<cr>  data() {<cr>    return {<cr>      <cr>    }<cr>  }<cr>}<cr></script><cr><cr><style scoped><cr><cr></style><esc>", "Vue : modèle SFC (Options API)")
      bmap("<leader>v3", "i<template><cr>  <div><cr>    <cr>  </div><cr></template><cr><cr><script setup lang=\"ts\"><cr>import { ref } from 'vue'<cr><cr>const count = ref(0)<cr></script><cr><cr><style scoped><cr><cr></style><esc>", "Vue : modèle SFC (Composition API)")
    end
  end,
})

project.report("web : formateur", function(bufnr)
  local ft = vim.bo[bufnr].filetype
  if not vim.tbl_contains(TS_FILETYPES, ft) and not vim.tbl_contains({ "css", "scss", "html", "json", "yaml", "markdown" }, ft) then
    return nil
  end
  local file = vim.api.nvim_buf_get_name(bufnr)
  local ctx = { buf = bufnr, filename = file, dirname = vim.fs.dirname(file) }
  if not M.has_prettier_config(ctx.dirname) then
    return "aucun Prettier (pas de config Prettier dans le projet)"
  end
  local argv = prettier_argv(ctx)
  return argv and table.concat(argv, " ") or "conteneur arrêté"
end)

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
