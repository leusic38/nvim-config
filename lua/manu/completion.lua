-- Complétion : blink.cmp (rapide, binaire de recherche floue précompilé, snippets natifs).
-- friendly-snippets : collection de snippets VS Code par langage, lue par blink.
-- Touches : préréglage « enter » de LazyVim (<CR> accepte, <C-space> ouvre, <C-n>/<C-p> naviguent).

vim.pack.add({
  { src = "https://github.com/saghen/blink.cmp", version = vim.version.range("1.*") },
  "https://github.com/rafamadriz/friendly-snippets",
}, { confirm = false })

require("blink.cmp").setup({
  keymap = { preset = "enter" },
  appearance = { nerd_font_variant = "mono" },
  completion = {
    accept = { auto_brackets = { enabled = true } },
    menu = { border = "rounded", draw = { treesitter = { "lsp" } } },
    documentation = { auto_show = true, auto_show_delay_ms = 200, window = { border = "rounded" } },
    ghost_text = { enabled = true },
  },
  signature = { window = { border = "rounded" } },
  sources = { default = { "lsp", "path", "snippets", "buffer" } },
  fuzzy = { implementation = "prefer_rust_with_warning" },
})

-- Capacités de complétion annoncées à tous les serveurs.
vim.lsp.config("*", { capabilities = require("blink.cmp").get_lsp_capabilities() })
