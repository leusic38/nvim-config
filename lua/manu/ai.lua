-- IA : Claude Code en CLI.
--
-- sidekick.nvim        : agents CLI (Claude Code) dans Neovim, un par worktree, sessions tmux
--   (config de l'ancienne lua/plugins/sidekick.lua ; suggestions « next edit » désactivées).
--   Glue Claude ↔ dossier courant : manu.agent ; worktrees : manu.worktree.
-- yank-for-claude.nvim : copie la sélection au format attendu par Claude (chemin + lignes).
-- Raccourcis perso de l'ancienne lua/plugins/ai.lua : Claude dans un onglet terminal
-- (simple, experts par stack, revue de code).

vim.pack.add({
  { src = "https://github.com/folke/sidekick.nvim", version = vim.version.range("2.*") },
  "https://github.com/wasabeef/yank-for-claude.nvim",
}, { confirm = false })

require("sidekick").setup({
  nes = { enabled = false },
  cli = {
    -- Sessions dans tmux : les agents survivent à la fermeture de Neovim et sont repris par
    -- <leader>as dans le même dossier.
    mux = { enabled = true, backend = "tmux" },
    tools = { claude = {} },
  },
})
require("yank-for-claude").setup({})

local map = vim.keymap.set

local function agent(fn, ...)
  local args = { ... }
  return function()
    require("manu.agent")[fn](unpack(args))
  end
end
local function worktree(fn)
  return function()
    require("manu.worktree")[fn]()
  end
end

-- ─── sidekick, worktrees ───────────────────────────────────────────────────
map("n", "<leader>as", agent("toggle"), { desc = "Claude (sidekick) du worktree" })
map("n", "<leader>aS", function()
  require("sidekick.cli").select({ filter = { installed = true } })
end, { desc = "Sidekick : choisir une session" })
map("n", "<leader>ad", function()
  require("sidekick.cli").close()
end, { desc = "Sidekick : détacher une session" })
map({ "n", "x" }, "<leader>at", agent("send", { msg = "{this}" }), { desc = "Claude : envoyer ceci" })
map("n", "<leader>af", agent("send", { msg = "{file}" }), { desc = "Claude : envoyer le fichier" })
map("x", "<leader>av", agent("send", { msg = "{selection}" }), { desc = "Claude : envoyer la sélection" })
map({ "n", "x" }, "<leader>ai", agent("prompt"), { desc = "Claude : prompts" })
map("n", "<leader>aw", worktree("switch"), { desc = "Worktree : changer" })
map("n", "<leader>aW", worktree("create"), { desc = "Worktree : créer + Claude" })
map("n", "<leader>ax", worktree("remove"), { desc = "Worktree : supprimer" })

-- ─── Claude dans un onglet terminal ────────────────────────────────────────

local function claude_tab(args, cwd)
  vim.cmd("tabnew")
  local cmd = "claude" .. (args and (" " .. vim.fn.shellescape(args)) or "")
  if cwd then
    cmd = "cd " .. vim.fn.shellescape(cwd) .. " && " .. cmd
  end
  vim.cmd.terminal(cmd)
  vim.cmd("startinsert")
end

--- Stacks présentes à la racine du projet.
local function detect_stacks(root)
  local stacks = {}
  local function has(pat)
    return #vim.fn.glob(root .. "/" .. pat, false, true) > 0
  end
  if has("composer.json") then
    table.insert(stacks, "PHP/Symfony")
  end
  if has("package.json") then
    table.insert(stacks, "JS/TS/Vue.js")
  end
  if has("*.gradle") or has("*.gradle.kts") then
    table.insert(stacks, "Kotlin")
  end
  if has("*.tf") then
    table.insert(stacks, "Terraform")
  end
  return stacks
end

--- Lance Claude en expert depuis la racine du projet (forced : un seul stack imposé).
local function launch_expert(forced)
  local root = vim.fs.root(0, { ".git", "composer.json", "package.json", "build.gradle.kts", "build.gradle", "settings.gradle.kts" })
    or vim.fn.getcwd()
  local stacks = forced and { forced } or detect_stacks(root)
  local desc = #stacks == 0 and "Adapte-toi au projet courant" or ("Stacks: " .. table.concat(stacks, ", "))
  claude_tab("Tu es un expert dev. " .. desc .. ". Respecte le CLAUDE.md du projet s'il existe.", root)
end

map("n", "<leader>aa", function()
  claude_tab()
end, { desc = "Claude dans un onglet terminal" })
map("x", "<leader>aq", function()
  local lines = vim.fn.getregion(vim.fn.getpos("v"), vim.fn.getpos("."), { type = vim.fn.mode() })
  vim.api.nvim_feedkeys(vim.keycode("<Esc>"), "n", false)
  claude_tab(table.concat(lines, "\n"))
end, { desc = "Envoyer la sélection à Claude (onglet)" })
map({ "n", "x" }, "<leader>ap", function()
  launch_expert()
end, { desc = "Claude expert (stacks détectées)" })
for key, stack in pairs({ p = "PHP/Symfony", j = "JS/TS/Vue.js", k = "Kotlin", t = "Terraform" }) do
  map({ "n", "x" }, "<leader>ae" .. key, function()
    launch_expert(stack)
  end, { desc = "Claude expert " .. stack })
end
map("n", "<leader>ar", function()
  local text = table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), "\n")
  claude_tab("Fais une révision de code: analyse les bugs, performance, lisibilité et bonnes pratiques\n\n```\n" .. text .. "\n```")
end, { desc = "Revue de code par Claude" })

map({ "n", "x" }, "<leader>yc", "<cmd>YankForClaude<cr>", { desc = "Copier pour Claude (chemin + lignes)" })
