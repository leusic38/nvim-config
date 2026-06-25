-- JavaScript/TypeScript/Vue development configuration
return {
  -- TypeScript LSP and tools
  {
    "pmizio/typescript-tools.nvim",
    dependencies = { "nvim-lua/plenary.nvim", "neovim/nvim-lspconfig" },
    opts = {
      settings = {
        -- TypeScript server configuration
        typescript = {
          inlayHints = {
            includeInlayParameterNameHints = "literal",
            includeInlayParameterNameHintsWhenArgumentMatchesName = false,
            includeInlayFunctionParameterTypeHints = true,
            includeInlayVariableTypeHints = false,
            includeInlayPropertyDeclarationTypeHints = true,
            includeInlayFunctionLikeReturnTypeHints = true,
            includeInlayEnumMemberValueHints = true,
          },
        },
        javascript = {
          inlayHints = {
            includeInlayParameterNameHints = "all",
            includeInlayParameterNameHintsWhenArgumentMatchesName = false,
            includeInlayFunctionParameterTypeHints = true,
            includeInlayVariableTypeHints = false,
            includeInlayPropertyDeclarationTypeHints = true,
            includeInlayFunctionLikeReturnTypeHints = true,
            includeInlayEnumMemberValueHints = true,
          },
        },
      },
    },
  },

  -- Vue.js support
  {
    "vuejs/language-tools",
    ft = { "vue" },
    dependencies = {
      "neovim/nvim-lspconfig",
      "pmizio/typescript-tools.nvim",
    },
    config = function()
      require("lspconfig").volar.setup({
        -- Configuration spécifique à Vue
        filetypes = { "typescript", "javascript", "javascriptreact", "typescriptreact", "vue", "json" },
        init_options = {
          vue = {
            hybridMode = false,
          },
          typescript = {
            tsdk = vim.fn.getcwd() .. "/node_modules/typescript/lib",
          },
        },
      })
    end,
  },

  -- ESLint integration
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      opts.servers = opts.servers or {}
      opts.servers.eslint = {
        settings = {
          workingDirectory = { mode = "auto" },
          format = true,
          lint = true,
        },
        on_attach = function(client, bufnr)
          vim.api.nvim_create_autocmd("BufWritePre", {
            buffer = bufnr,
            command = "EslintFixAll",
          })
        end,
      }
    end,
  },

  -- Prettier and formatting
  {
    "stevearc/conform.nvim",
    opts = function(_, opts)
      opts.formatters_by_ft = opts.formatters_by_ft or {}
      opts.formatters_by_ft.javascript = { "prettier" }
      opts.formatters_by_ft.typescript = { "prettier" }
      opts.formatters_by_ft.javascriptreact = { "prettier" }
      opts.formatters_by_ft.typescriptreact = { "prettier" }
      opts.formatters_by_ft.vue = { "prettier" }
      opts.formatters_by_ft.css = { "prettier" }
      opts.formatters_by_ft.scss = { "prettier" }
      opts.formatters_by_ft.html = { "prettier" }
      opts.formatters_by_ft.json = { "prettier" }
      opts.formatters_by_ft.jsonc = { "prettier" }
      opts.formatters_by_ft.yaml = { "prettier" }
      opts.formatters_by_ft.markdown = { "prettier" }

      -- Configuration Prettier
      opts.formatters = opts.formatters or {}
      opts.formatters.prettier = {
        command = "prettier",
        args = {
          "--stdin-filepath",
          "$FILENAME",
          "--config-precedence",
          "prefer-file",
        },
        range_args = function()
          return {
            "--stdin-filepath",
            "$FILENAME",
            "--range-start",
            "$RANGE_START",
            "--range-end",
            "$RANGE_END",
          }
        end,
        env = {
          PRETTIER_DEFAULT_CONFIG = vim.fn.expand("~/.config/nvim/prettier.config.js"),
        },
      }
    end,
  },

  -- Linting with nvim-lint
  {
    "mfussenegger/nvim-lint",
    opts = function(_, opts)
      opts.linters_by_ft = opts.linters_by_ft or {}
      opts.linters_by_ft.javascript = { "eslint_d" }
      opts.linters_by_ft.typescript = { "eslint_d" }
      opts.linters_by_ft.javascriptreact = { "eslint_d" }
      opts.linters_by_ft.typescriptreact = { "eslint_d" }
      opts.linters_by_ft.vue = { "eslint_d" }
    end,
  },

  -- Testing with neotest
  {
    "nvim-neotest/neotest",
    optional = true,
    dependencies = {
      "nvim-neotest/neotest-jest",
      "marilari88/neotest-vitest",
    },
    opts = function(_, opts)
      opts.adapters = opts.adapters or {}
      vim.list_extend(opts.adapters, {
        require("neotest-jest")({
          jestCommand = "npm test --",
          jestConfigFile = "jest.config.js",
          env = { CI = true },
          cwd = function()
            return vim.fn.getcwd()
          end,
        }),
        require("neotest-vitest")({
          filter_dir = function(name)
            return name ~= "node_modules"
          end,
        }),
      })
    end,
  },

  -- Debugging with nvim-dap (Mason-managed js-debug-adapter, no build step)
  {
    "mfussenegger/nvim-dap",
    optional = true,
    opts = function()
      local dap = require("dap")
      local js_debug_path = vim.fn.stdpath("data") .. "/mason/packages/js-debug-adapter"

      for _, adapter in ipairs({ "pwa-node", "pwa-chrome", "pwa-msedge", "node-terminal", "pwa-extensionHost" }) do
        dap.adapters[adapter] = {
          type = "server",
          host = "localhost",
          port = "${port}",
          executable = {
            command = "node",
            args = { js_debug_path .. "/js-debug/src/dapDebugServer.js", "${port}" },
          },
        }
      end

      for _, language in ipairs({ "javascript", "typescript" }) do
        dap.configurations[language] = {
          {
            type = "pwa-node",
            request = "launch",
            name = "Launch Node.js Program",
            program = "${file}",
            cwd = "${workspaceFolder}",
            sourceMaps = true,
            skipFiles = { "<node_internals>/**" },
          },
          {
            type = "pwa-node",
            request = "attach",
            name = "Attach to Node.js Process",
            processId = require('dap.utils').pick_process,
            cwd = "${workspaceFolder}",
            sourceMaps = true,
            skipFiles = { "<node_internals>/**" },
          },
          {
            type = "pwa-node",
            request = "launch",
            name = "Debug Jest Tests",
            runtimeExecutable = "node",
            runtimeArgs = {
              "./node_modules/jest/bin/jest.js",
              "--runInBand",
            },
            rootPath = "${workspaceFolder}",
            cwd = "${workspaceFolder}",
            console = "integratedTerminal",
            internalConsoleOptions = "neverOpen",
            skipFiles = { "<node_internals>/**" },
          },
        }
      end
    end,
  },

  -- Package management integration
  {
    "vuki656/package-info.nvim",
    ft = "json",
    dependencies = { "MunifTanjim/nui.nvim" },
    config = function()
      require("package-info").setup({
        colors = {
          up_to_date = "#3C4048",
          outdated = "#d19a66",
        },
        icons = {
          enable = true,
          style = {
            up_to_date = "|  ",
            outdated = "|  ",
          },
        },
        autostart = true,
        hide_up_to_date = false,
        hide_unstable_versions = false,
      })
    end,
    keys = {
      { "<leader>jps", "<cmd>lua require('package-info').show()<cr>", desc = "JS: Show package info" },
      { "<leader>jpc", "<cmd>lua require('package-info').hide()<cr>", desc = "JS: Hide package info" },
      { "<leader>jpt", "<cmd>lua require('package-info').toggle()<cr>", desc = "JS: Toggle package info" },
      { "<leader>jpu", "<cmd>lua require('package-info').update()<cr>", desc = "JS: Update package" },
      { "<leader>jpd", "<cmd>lua require('package-info').delete()<cr>", desc = "JS: Delete package" },
      { "<leader>jpi", "<cmd>lua require('package-info').install()<cr>", desc = "JS: Install package" },
      { "<leader>jpv", "<cmd>lua require('package-info').change_version()<cr>", desc = "JS: Change package version" },
    },
  },

  -- Auto-imports and code actions
  {
    "pmizio/typescript-tools.nvim",
    keys = {
      { "<leader>jlo", "<cmd>TSToolsOrganizeImports<cr>", desc = "JS: Organize imports" },
      { "<leader>jls", "<cmd>TSToolsSortImports<cr>", desc = "JS: Sort imports" },
      { "<leader>jlu", "<cmd>TSToolsRemoveUnusedImports<cr>", desc = "JS: Remove unused imports" },
      { "<leader>jlg", "<cmd>TSToolsGoToSourceDefinition<cr>", desc = "JS: Go to source definition" },
      { "<leader>jlr", "<cmd>TSToolsRenameFile<cr>", desc = "JS: Rename file" },
      { "<leader>jla", "<cmd>TSToolsAddMissingImports<cr>", desc = "JS: Add missing imports" },
    },
  },

  -- Enhanced syntax highlighting
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, {
        "javascript",
        "typescript",
        "tsx",
        "vue",
        "css",
        "scss",
        "html",
        "json",
        "jsonc",
        "jsdoc",
      })
    end,
  },

  -- Vue specific treesitter
  {
    "nvim-treesitter/nvim-treesitter",
    dependencies = {
      "windwp/nvim-ts-autotag",
    },
    opts = function(_, opts)
      opts.autotag = {
        enable = true,
        enable_rename = true,
        enable_close = true,
        enable_close_on_slash = true,
        filetypes = {
          "html",
          "javascript",
          "typescript",
          "javascriptreact",
          "typescriptreact",
          "svelte",
          "vue",
          "tsx",
          "jsx",
          "rescript",
          "xml",
          "php",
          "markdown",
          "glimmer",
          "handlebars",
          "hbs",
        },
      }
    end,
  },
}