-- Configuration Claude Code avec connection normale

-- Racine du projet courant (git ou marqueurs de build), fallback cwd
local function project_root()
  local root = vim.fs.root(0, {
    ".git",
    "composer.json",
    "package.json",
    "build.gradle.kts",
    "build.gradle",
    "settings.gradle.kts",
  })
  return root or vim.fn.getcwd()
end

-- Détecte les stacks présents à la racine du projet
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

-- Lance Claude en expert depuis la racine du projet (lit le CLAUDE.md du projet)
-- forced: si fourni, force un seul stack ; sinon auto-détection multi-stack
local function launch_expert(forced)
  local root = project_root()
  local stacks = forced and { forced } or detect_stacks(root)
  local desc
  if #stacks == 0 then
    desc = "Adapte-toi au projet courant"
  else
    desc = "Stacks: " .. table.concat(stacks, ", ")
  end
  local prompt = "Tu es un expert dev. " .. desc .. ". Respecte le CLAUDE.md du projet s'il existe."
  vim.cmd("tabnew")
  vim.cmd("terminal cd " .. vim.fn.shellescape(root) .. " && claude " .. vim.fn.shellescape(prompt))
  vim.cmd("startinsert")
end

return {
  -- Interface Claude simple via terminal
  {
    "nvim-lua/plenary.nvim",
    keys = {
      -- Interface Claude via terminal
      {
        "<leader>aa",
        function()
          vim.cmd("tabnew")
          vim.cmd("terminal claude")
          vim.cmd("startinsert")
        end,
        desc = "Open Claude in terminal"
      },

      -- Envoyer la sélection à Claude
      {
        "<leader>aq",
        function()
          local lines = vim.fn.getline("'<", "'>")
          local text = table.concat(lines, "\n")
          local escaped_text = vim.fn.shellescape(text)
          vim.cmd("tabnew")
          vim.cmd("terminal claude " .. escaped_text)
          vim.cmd("startinsert")
        end,
        mode = "v",
        desc = "Send selection to Claude"
      },

      -- Expert auto : détecte tous les stacks du projet courant
      {
        "<leader>ap",
        function()
          launch_expert()
        end,
        mode = { "n", "v" },
        desc = "Claude Expert (auto)"
      },

      -- Experts forcés par langage
      {
        "<leader>aep",
        function()
          launch_expert("PHP/Symfony")
        end,
        mode = { "n", "v" },
        desc = "Claude Expert PHP"
      },
      {
        "<leader>aej",
        function()
          launch_expert("JS/TS/Vue.js")
        end,
        mode = { "n", "v" },
        desc = "Claude Expert JS/TS/Vue"
      },
      {
        "<leader>aek",
        function()
          launch_expert("Kotlin")
        end,
        mode = { "n", "v" },
        desc = "Claude Expert Kotlin"
      },
      {
        "<leader>aet",
        function()
          launch_expert("Terraform")
        end,
        mode = { "n", "v" },
        desc = "Claude Expert Terraform"
      },

      -- Code Review
      {
        "<leader>ar",
        function()
          local review_prompt = "Fais une révision de code: analyse les bugs, performance, lisibilité et bonnes pratiques"
          local lines = vim.fn.getline(1, "$")
          local text = table.concat(lines, "\n")
          local full_prompt = review_prompt .. "\n\n```\n" .. text .. "\n```"
          local escaped_prompt = vim.fn.shellescape(full_prompt)
          vim.cmd("tabnew")
          vim.cmd("terminal claude " .. escaped_prompt)
          vim.cmd("startinsert")
        end,
        desc = "Code Review with Claude"
      },
    },
  },

  -- Yank for Claude - helper pour partager le contexte de code
  {
    "wasabeef/yank-for-claude.nvim",
    keys = {
      { "<leader>yc", "<cmd>YankForClaude<cr>", mode = { "n", "v" }, desc = "Yank for Claude format" },
    },
  },
}
