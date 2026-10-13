-- Prise en charge Twig.
--
--   * Coloration : parser treesitter `twig`, dont les requêtes injectent `html`
--     dans le contenu hors balises Twig (le parser `html` est déjà installé).
--   * LSP : twiggy-language-server (complétion des fonctions/filtres/globals,
--     hover, navigation entre templates, blocks et macros). Config du serveur et
--     gestion Docker : lsp/twiggy_language_server.lua. symfony_lsp s'attache
--     aussi aux buffers twig (lsp/symfony_lsp.lua).
--   * Lint / formatage : Twig-CS-Fixer. Le binaire du projet
--     (`vendor/bin/twig-cs-fixer`) est préféré, Mason fournit le repli.
--
-- Le formatage à la sauvegarde n'est actif que si le projet déclare une config
-- Twig-CS-Fixer : sans elle, les règles par défaut réécriraient des templates
-- qui n'ont jamais suivi ce standard (ex. lama, ~1 900 templates). Le lint, lui,
-- ne fait qu'afficher des diagnostics et reste actif partout.
--
-- Pas d'extra LazyVim `lang.twig` : il installe aussi twigcs (abandonné au
-- profit de Twig-CS-Fixer) et formate sans condition.
--
-- `gd` sur un nom de template : lua/config/symfony-goto.lua.

local twig_cs_fixer_configs = { ".twig-cs-fixer.php", ".twig-cs-fixer.dist.php" }

return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = { ensure_installed = { "twig" } },
  },

  {
    "mason-org/mason.nvim",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, { "twig-cs-fixer" })
    end,
  },

  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        twiggy_language_server = {},
      },
    },
  },

  {
    "mfussenegger/nvim-lint",
    optional = true,
    opts = {
      linters_by_ft = {
        twig = { "twig-cs-fixer" },
      },
    },
  },

  {
    "stevearc/conform.nvim",
    optional = true,
    opts = {
      formatters_by_ft = {
        twig = { "twig-cs-fixer" },
      },
      formatters = {
        ["twig-cs-fixer"] = {
          condition = function(_, ctx)
            return vim.fs.root(ctx.dirname, twig_cs_fixer_configs) ~= nil
          end,
        },
      },
    },
  },
}
