-- Langage Markdown (suit le modèle de lang/lua.lua).
--
-- render-markdown.nvim : affiche le Markdown mis en forme dans le buffer (titres, listes,
--   tableaux, cases à cocher, blocs de code) ; la ligne en cours d'édition reste brute.
-- Aperçu navigateur : <leader>H (manu.keymaps, via le script mdview).
-- markdownlint-cli2 : lint toujours actif, avec la config de neovimanu
--   (.markdownlint-cli2.jsonc : longueur de ligne, HTML et 1er titre libres).
-- Formatage à l'enregistrement : Prettier si le projet l'a configuré, puis
--   markdownlint-cli2 --fix si le projet a sa propre config markdownlint.

vim.pack.add({
  { src = "https://github.com/MeanderingProgrammer/render-markdown.nvim", version = vim.version.range("8.*") },
}, { confirm = false })

require("render-markdown").setup({
  file_types = { "markdown" },
  completions = { blink = { enabled = true } },
})

vim.keymap.set("n", "<leader>um", function()
  require("render-markdown").toggle()
  vim.notify((require("render-markdown.state").enabled and "Activé" or "Désactivé") .. " : rendu Markdown")
end, { desc = "Basculer le rendu Markdown" })

require("manu.treesitter").install({ "markdown", "markdown_inline", "html", "latex", "yaml" })

require("manu.mason").ensure({ "markdownlint-cli2" })

local MD_CONFIG = vim.fn.stdpath("config") .. "/.markdownlint-cli2.jsonc"
local MD_PROJECT_CONFIGS = {
  ".markdownlint-cli2.jsonc", ".markdownlint-cli2.yaml", ".markdownlint-cli2.cjs", ".markdownlint-cli2.mjs",
  ".markdownlint.json", ".markdownlint.jsonc", ".markdownlint.yaml", ".markdownlint.yml",
}

local lint = require("lint")
lint.linters.markdownlint_manu = vim.tbl_extend("force", require("lint.linters.markdownlint-cli2"), {
  args = { "--config", MD_CONFIG, "-" },
})
lint.linters_by_ft.markdown = { "markdownlint_manu" }

require("conform").formatters.markdownlint_fix_project = {
  command = "markdownlint-cli2",
  args = { "--fix", "$FILENAME" },
  stdin = false,
  condition = function(_, ctx)
    return require("manu.format").project_has(MD_PROJECT_CONFIGS, ctx.buf)
  end,
  cwd = function(_, ctx)
    return vim.fs.root(ctx.buf, MD_PROJECT_CONFIGS)
  end,
}
require("conform").formatters_by_ft.markdown = { "prettier_project", "markdownlint_fix_project" }

vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("manu_markdown_keymaps", { clear = true }),
  pattern = "markdown",
  callback = function(ev)
    local function bmap(lhs, rhs, desc)
      vim.keymap.set("n", lhs, rhs, { buffer = ev.buf, desc = desc })
    end
    bmap("<leader>mf", function()
      require("conform").format({ bufnr = ev.buf, async = true })
    end, "Markdown : formater")
    bmap("<leader>ml", function()
      lint.try_lint("markdownlint_manu")
    end, "Markdown : lancer markdownlint")
    bmap("<leader>mc", function()
      require("conform").format({ bufnr = ev.buf, async = true }, function()
        vim.defer_fn(function()
          lint.try_lint("markdownlint_manu")
        end, 200)
      end)
    end, "Markdown : formater puis linter")
    bmap("<leader>ma", vim.lsp.buf.code_action, "Markdown : actions de code")
  end,
})
