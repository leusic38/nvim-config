-- JavaScript/TypeScript/Vue development configuration
return {
  -- TypeScript LSP: vtsls (from the LazyVim typescript/vue extras) with our inlay hints
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
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

      opts.servers = opts.servers or {}
      opts.servers.vtsls = vim.tbl_deep_extend("force", opts.servers.vtsls or {}, {
        settings = {
          typescript = { inlayHints = inlay_hints("literals") },
          javascript = { inlayHints = inlay_hints("all") },
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
      -- Code filetypes: Prettier only when the project ships a Prettier config,
      -- and never an LSP fallback (volar/tsserver would impose their own style).
      -- Projects without Prettier (e.g. lama) are then formatted by ESLint only,
      -- through the EslintFixAll BufWritePre above — same result as PhpStorm.
      for _, ft in ipairs({
        "javascript",
        "typescript",
        "javascriptreact",
        "typescriptreact",
        "vue",
        "css",
        "scss",
        "html",
      }) do
        opts.formatters_by_ft[ft] = { "prettier", lsp_format = "never" }
      end
      opts.formatters_by_ft.json = { "prettier" }
      opts.formatters_by_ft.jsonc = { "prettier" }
      opts.formatters_by_ft.yaml = { "prettier" }
      opts.formatters_by_ft.markdown = { "prettier" }

      -- Configuration Prettier
      opts.formatters = opts.formatters or {}

      -- YAML : 2 espaces, quoi que dise le .prettierrc du projet (pendant de
      -- l'override editorconfig dans lua/config/options.lua). Pour les autres
      -- filetypes on garde `prefer-file` : la config du projet fait loi.
      -- Sur YAML on bascule en `cli-override` — le .prettierrc est toujours lu
      -- et appliqué, seul tabWidth/useTabs est écrasé par la ligne de commande.
      local function prettier_args(_, ctx)
        local args = { "--stdin-filepath", "$FILENAME" }
        if vim.bo[ctx.buf].filetype:match("^yaml") then
          vim.list_extend(args, {
            "--config-precedence",
            "cli-override",
            "--tab-width",
            "2",
            "--use-tabs",
            "false",
          })
        else
          vim.list_extend(args, { "--config-precedence", "prefer-file" })
        end
        return args
      end

      local prettier_project_only = {
        javascript = true,
        typescript = true,
        javascriptreact = true,
        typescriptreact = true,
        vue = true,
        css = true,
        scss = true,
        html = true,
      }
      local prettier_config_files = {
        ".prettierrc",
        ".prettierrc.json",
        ".prettierrc.yml",
        ".prettierrc.yaml",
        ".prettierrc.json5",
        ".prettierrc.js",
        ".prettierrc.cjs",
        ".prettierrc.mjs",
        ".prettierrc.ts",
        ".prettierrc.toml",
        "prettier.config.js",
        "prettier.config.cjs",
        "prettier.config.mjs",
        "prettier.config.ts",
      }

      local function has_prettier_config(dirname)
        if vim.fs.find(prettier_config_files, { path = dirname, upward = true })[1] then
          return true
        end
        local package_json = vim.fs.find("package.json", { path = dirname, upward = true })[1]
        if not package_json then
          return false
        end
        local ok, content = pcall(vim.fn.readfile, package_json)
        if not ok then
          return false
        end
        local decoded_ok, decoded = pcall(vim.json.decode, table.concat(content, "\n"))
        return decoded_ok and type(decoded) == "table" and decoded.prettier ~= nil
      end

      opts.formatters.prettier = {
        command = "prettier",
        condition = function(_, ctx)
          if not prettier_project_only[vim.bo[ctx.buf].filetype] then
            return true
          end
          return has_prettier_config(ctx.dirname)
        end,
        args = prettier_args,
        range_args = function(self, ctx)
          local args = prettier_args(self, ctx)
          vim.list_extend(args, {
            "--range-start",
            "$RANGE_START",
            "--range-end",
            "$RANGE_END",
          })
          return args
        end,
        env = {
          PRETTIER_DEFAULT_CONFIG = vim.fn.expand("~/.config/nvim/prettier.config.js"),
        },
      }
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
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      opts.servers = opts.servers or {}
      opts.servers.vtsls = opts.servers.vtsls or {}
      opts.servers.vtsls.keys = opts.servers.vtsls.keys or {}
      vim.list_extend(opts.servers.vtsls.keys, {
        { "<leader>jlo", LazyVim.lsp.action["source.organizeImports"], desc = "JS: Organize imports" },
        { "<leader>jls", LazyVim.lsp.action["source.sortImports"], desc = "JS: Sort imports" },
        { "<leader>jlu", LazyVim.lsp.action["source.removeUnused.ts"], desc = "JS: Remove unused imports" },
        {
          "<leader>jlg",
          function()
            local params = vim.lsp.util.make_position_params(0, "utf-16")
            LazyVim.lsp.execute({
              command = "typescript.goToSourceDefinition",
              arguments = { params.textDocument.uri, params.position },
              open = true,
            })
          end,
          desc = "JS: Go to source definition",
        },
        { "<leader>jlr", function() Snacks.rename.rename_file() end, desc = "JS: Rename file" },
        { "<leader>jla", LazyVim.lsp.action["source.addMissingImports.ts"], desc = "JS: Add missing imports" },
      })
    end,
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