return {
  -- Kotlin LSP Support
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        kotlin_language_server = {
          settings = {
            kotlin = {
              compiler = {
                jvm = {
                  target = "17",
                },
              },
              inlayHints = {
                typeHints = true,
                parameterHints = true,
                chainedHints = true,
              },
              linting = {
                debounceTime = 250,
              },
            },
          },
        },
      },
    },
  },

  -- Formatting with ktlint
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        kotlin = { "ktlint" },
      },
      formatters = {
        ktlint = {
          command = "ktlint",
          args = { "--format", "--stdin", "$FILENAME" },
        },
      },
    },
  },

  -- Linting with ktlint
  {
    "mfussenegger/nvim-lint",
    opts = {
      linters_by_ft = {
        kotlin = { "ktlint" },
      },
      linters = {
        ktlint = {
          cmd = "ktlint",
          stdin = true,
          args = { "--reporter=json", "--stdin" },
          stream = "stdout",
          ignore_exitcode = true,
          parser = function(output, bufnr)
            local diagnostics = {}
            local ok, decoded = pcall(vim.json.decode, output)
            if not ok or not decoded then
              return diagnostics
            end

            for _, file_errors in ipairs(decoded) do
              if file_errors.errors then
                for _, error in ipairs(file_errors.errors) do
                  table.insert(diagnostics, {
                    lnum = error.line - 1,
                    col = error.column - 1,
                    end_lnum = error.line - 1,
                    end_col = error.column,
                    severity = vim.diagnostic.severity.WARN,
                    message = error.message,
                    source = "ktlint",
                    code = error.rule,
                  })
                end
              end
            end

            return diagnostics
          end,
        },
      },
    },
  },

  -- Testing with neotest
  {
    "nvim-neotest/neotest",
    dependencies = {
      "rcasia/neotest-java",
    },
    opts = function(_, opts)
      opts.adapters = opts.adapters or {}
      table.insert(
        opts.adapters,
        require("neotest-java")({
          ignore_wrapper = false,
        })
      )
    end,
  },

  -- Debugging with nvim-dap
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "nvim-neotest/nvim-nio",
    },
    opts = function()
      local dap = require("dap")

      -- Kotlin debugger configuration (uses Java DAP)
      dap.configurations.kotlin = {
        {
          type = "java",
          request = "attach",
          name = "Debug (Attach) - Remote",
          hostName = "127.0.0.1",
          port = 5005,
        },
        {
          type = "java",
          request = "launch",
          name = "Debug (Launch)",
          classPaths = {},
          mainClass = function()
            return vim.fn.input("Main class: ", "", "file")
          end,
          projectName = function()
            return vim.fn.input("Project name: ")
          end,
        },
      }
    end,
  },

  -- Java Debug Adapter (for Kotlin debugging)
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      {
        "mason-org/mason.nvim",
        opts = function(_, opts)
          opts.ensure_installed = opts.ensure_installed or {}
          vim.list_extend(opts.ensure_installed, { "java-debug-adapter" })
        end,
      },
    },
    opts = function()
      local dap = require("dap")
      if not dap.adapters.java then
        dap.adapters.java = function(callback, config)
          callback({
            type = "server",
            host = config.hostName or "127.0.0.1",
            port = config.port or 5005,
          })
        end
      end
    end,
  },

  -- Kotlin Treesitter Support
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      if type(opts.ensure_installed) == "table" then
        vim.list_extend(opts.ensure_installed, { "kotlin" })
      end
    end,
  },

  -- Gradle integration
  {
    "nvim-lua/plenary.nvim",
  },

  -- Load Kotlin-specific keymaps
  {
    "folke/which-key.nvim",
    opts = function(_, opts)
      -- Load keymaps for Kotlin files
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "kotlin",
        callback = function()
          local ok, _ = pcall(require, "config.kotlin-keymaps")
          if not ok then
            vim.notify("Failed to load Kotlin keymaps", vim.log.levels.WARN)
          end
        end,
      })
    end,
  },
}
