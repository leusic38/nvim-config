return {
  -- Markdownlint via nvim-lint
  {
    "mfussenegger/nvim-lint",
    optional = true,
    opts = {
      linters_by_ft = {
        markdown = { "markdownlint-cli2" },
      },
      linters = {
        ["markdownlint-cli2"] = {
          args = {
            "--config",
            vim.fn.stdpath("config") .. "/.markdownlint-cli2.jsonc",
          },
        },
      },
    },
  },

  -- Formatage Markdown avec prettier + markdownlint auto-fix
  {
    "stevearc/conform.nvim",
    optional = true,
    opts = {
      formatters_by_ft = {
        -- D'abord prettier pour le formatage général, puis markdownlint pour corriger les règles MD
        markdown = { "prettier", "markdownlint-cli2" },
      },
      formatters = {
        ["markdownlint-cli2"] = {
          command = "markdownlint-cli2",
          args = {
            "--fix",
            "--config",
            vim.fn.stdpath("config") .. "/.markdownlint-cli2.jsonc",
            "$FILENAME",
          },
          stdin = false,
        },
      },
    },
  },

  -- Auto-installation des outils Markdown via Mason
  {
    "mason-org/mason.nvim",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, {
        "markdownlint-cli2",
        "prettier",
      })
    end,
  },
}
