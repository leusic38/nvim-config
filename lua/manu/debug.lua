-- Débogage pas à pas.
--
-- nvim-dap                    : client DAP (points d'arrêt, pas à pas, évaluation).
-- nvim-dap-ui                 : panneaux variables / points d'arrêt / pile / console, en 3
--                               dispositions perso (<leader>du compacte, <leader>dU complète).
-- nvim-dap-virtual-text       : valeurs des variables affichées dans le code.
-- persistent-breakpoints.nvim : points d'arrêt conservés d'une session à l'autre.
-- nvim-nio                    : bibliothèque asynchrone requise par nvim-dap-ui (et neotest).
--
-- Les langages déclarent adaptateurs et configurations par défaut avec M.adapter() et
-- M.defaults(). Un projet peut les remplacer par <racine>/.nvim/dap.lua : une fonction
-- function(dap) … end, ou une table { [filetype] = { configurations… } }. Relu à chaque
-- changement de dossier (:cd, onglet de worktree).

vim.pack.add({
  "https://github.com/nvim-neotest/nvim-nio",
  "https://github.com/mfussenegger/nvim-dap",
  "https://github.com/rcarriga/nvim-dap-ui",
  "https://github.com/theHamsta/nvim-dap-virtual-text",
  "https://github.com/Weissle/persistent-breakpoints.nvim",
}, { confirm = false })

local dap = require("dap")
local dapui = require("dapui")

local M = {}

-- ─── Signes ────────────────────────────────────────────────────────────────
vim.fn.sign_define("DapBreakpoint", { text = "●", texthl = "DiagnosticError" })
vim.fn.sign_define("DapBreakpointCondition", { text = "◆", texthl = "DiagnosticWarn" })
vim.fn.sign_define("DapBreakpointRejected", { text = "○", texthl = "DiagnosticHint" })
vim.fn.sign_define("DapLogPoint", { text = "◉", texthl = "DiagnosticInfo" })
vim.fn.sign_define("DapStopped", { text = "▶", texthl = "DiagnosticWarn", linehl = "DapStoppedLine", numhl = "DapStoppedLine" })
vim.api.nvim_set_hl(0, "DapStoppedLine", { bg = "#2D3748", default = true })

-- ─── Interface ─────────────────────────────────────────────────────────────
dapui.setup({
  icons = { expanded = "▾", collapsed = "▸", current_frame = "▸" },
  mappings = { expand = { "<CR>", "<2-LeftMouse>" }, open = "o", remove = "d", edit = "e", repl = "r", toggle = "t" },
  layouts = {
    -- 1 : compacte (variables + points d'arrêt)
    { elements = { { id = "scopes", size = 0.6 }, { id = "breakpoints", size = 0.4 } }, size = 0.28, position = "right" },
    -- 2 : complète (variables, points d'arrêt, pile, expressions surveillées)
    {
      elements = {
        { id = "scopes", size = 0.33 },
        { id = "breakpoints", size = 0.17 },
        { id = "stacks", size = 0.25 },
        { id = "watches", size = 0.25 },
      },
      size = 0.33,
      position = "right",
    },
    -- 3 : console (REPL + sortie du programme), en bas
    { elements = { { id = "repl", size = 0.45 }, { id = "console", size = 0.55 } }, size = 0.27, position = "bottom" },
  },
  floating = { max_height = 0.9, max_width = 0.5, border = "rounded", mappings = { close = { "q", "<Esc>" } } },
})
-- Disposition compacte ouverte au démarrage d'une session, tout fermé à la fin.
dap.listeners.after.event_initialized["manu_dapui"] = function()
  dapui.open({ layout = 1 })
end
dap.listeners.before.event_terminated["manu_dapui"] = function()
  dapui.close()
end
dap.listeners.before.event_exited["manu_dapui"] = function()
  dapui.close()
end

require("nvim-dap-virtual-text").setup({ enabled = true, commented = true })
require("persistent-breakpoints").setup({ load_breakpoints_event = { "BufReadPost" } })

-- ─── Adaptateurs et configurations ─────────────────────────────────────────

---@type table<string, table[]|fun(): table[]>
local defaults = {}

--- Déclare un adaptateur DAP.
function M.adapter(name, def)
  dap.adapters[name] = def
end

--- Configurations par défaut d'un filetype (table, ou fonction évaluée au chargement, pour
--- dépendre du projet courant : chemins conteneur…).
---@param ft string
---@param configs table[]|fun(): table[]
function M.defaults(ft, configs)
  defaults[ft] = configs
  M.load_project()
end

--- Applique les configurations par défaut, puis celles du projet (.nvim/dap.lua).
function M.load_project()
  for ft, configs in pairs(defaults) do
    dap.configurations[ft] = type(configs) == "function" and configs() or vim.deepcopy(configs)
  end
  local path = assert(vim.uv.cwd()) .. "/.nvim/dap.lua"
  if not vim.uv.fs_stat(path) then
    return
  end
  local ok, project_config = pcall(dofile, path)
  if not ok then
    vim.notify(".nvim/dap.lua : " .. tostring(project_config), vim.log.levels.ERROR)
  elseif type(project_config) == "function" then
    project_config(dap)
  elseif type(project_config) == "table" then
    for ft, configs in pairs(project_config) do
      dap.configurations[ft] = configs
    end
  end
end

vim.api.nvim_create_autocmd("DirChanged", {
  group = vim.api.nvim_create_augroup("manu_debug", { clear = true }),
  callback = function()
    M.load_project()
  end,
})

-- ─── Raccourcis (touches LazyVim de l'extra dap.core, cochées au tri) ───────

local map = vim.keymap.set
local pb = require("persistent-breakpoints.api")

--- <leader>da : demande les arguments du programme avant de lancer.
local function continue_with_args()
  vim.ui.input({ prompt = "Arguments : " }, function(input)
    if input == nil then
      return
    end
    dap.continue({
      before = function(cfg)
        cfg = vim.deepcopy(cfg)
        cfg.args = vim.split(input, " ", { trimempty = true })
        return cfg
      end,
    })
  end)
end

map("n", "<leader>db", function()
  pb.toggle_breakpoint()
end, { desc = "Point d'arrêt (basculer)" })
map("n", "<leader>dB", function()
  pb.set_conditional_breakpoint()
end, { desc = "Point d'arrêt conditionnel" })
map("n", "<leader>dc", function()
  dap.continue()
end, { desc = "Lancer / continuer" })
map("n", "<leader>da", continue_with_args, { desc = "Lancer avec des arguments" })
map("n", "<leader>dC", function()
  dap.run_to_cursor()
end, { desc = "Continuer jusqu'au curseur" })
map("n", "<leader>dg", function()
  dap.goto_()
end, { desc = "Aller à la ligne (sans exécuter)" })
map("n", "<leader>di", function()
  dap.step_into()
end, { desc = "Entrer (step into)" })
map("n", "<leader>dO", function()
  dap.step_over()
end, { desc = "Pas suivant (step over)" })
map("n", "<leader>do", function()
  dap.step_out()
end, { desc = "Sortir (step out)" })
map("n", "<leader>dj", function()
  dap.down()
end, { desc = "Descendre dans la pile" })
map("n", "<leader>dk", function()
  dap.up()
end, { desc = "Remonter dans la pile" })
map("n", "<leader>dl", function()
  dap.run_last()
end, { desc = "Relancer la dernière session" })
map("n", "<leader>dP", function()
  dap.pause()
end, { desc = "Pause" })
map("n", "<leader>dr", function()
  dap.repl.toggle()
end, { desc = "REPL (basculer)" })
map("n", "<leader>ds", function()
  dap.session()
end, { desc = "Session courante" })
map("n", "<leader>dt", function()
  dap.terminate()
end, { desc = "Arrêter" })
map("n", "<leader>dw", function()
  require("dap.ui.widgets").hover()
end, { desc = "Valeur sous le curseur (widget)" })
map({ "n", "x" }, "<leader>de", function()
  dapui.eval()
end, { desc = "Évaluer l'expression" })
map("n", "<leader>du", function()
  dapui.close({ layout = 2 })
  dapui.close({ layout = 3 })
  dapui.toggle({ layout = 1 })
end, { desc = "Interface de débogage compacte" })
map("n", "<leader>dU", function()
  dapui.close({ layout = 1 })
  dapui.toggle({ layout = 2 })
  dapui.toggle({ layout = 3 })
end, { desc = "Interface de débogage complète" })

return M
