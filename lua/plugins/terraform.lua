return {
  -- Terraform formatting with terraform fmt
  {
    "stevearc/conform.nvim",
    optional = true,
    lazy = true,
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      formatters_by_ft = {
        terraform = { "terraform_fmt" },
        tf = { "terraform_fmt" },
        hcl = { "terraform_fmt" },
      },
      formatters = {
        terraform_fmt = {
          command = "terraform",
          args = { "fmt", "-" },
          stdin = true,
        },
      },
      notify_on_error = true,
    },
  },

  -- Terraform validation and linting via nvim-lint
  {
    "mfussenegger/nvim-lint",
    optional = true,
    opts = {
      linters_by_ft = {
        terraform = { "terraform_validate" },
        tf = { "terraform_validate" },
      },
      linters = {
        terraform_validate = {
          cmd = "terraform",
          stdin = false,
          args = {
            "validate",
            "-json",
            "-no-color",
          },
          stream = "stdout",
          ignore_exitcode = true,
          parser = function(output, bufnr)
            local items = {}
            local ok, decoded = pcall(vim.json.decode, output)
            if not ok or not decoded.diagnostics then
              return items
            end

            for _, diagnostic in ipairs(decoded.diagnostics) do
              if diagnostic.range then
                table.insert(items, {
                  lnum = diagnostic.range.start.line,
                  col = diagnostic.range.start.column,
                  end_lnum = diagnostic.range["end"].line,
                  end_col = diagnostic.range["end"].column,
                  message = diagnostic.summary .. (diagnostic.detail and ": " .. diagnostic.detail or ""),
                  severity = diagnostic.severity == "error" and vim.diagnostic.severity.ERROR or vim.diagnostic.severity.WARN,
                })
              end
            end
            return items
          end,
        },
      },
    },
  },

  -- Enhanced Terraform syntax and LSP
  {
    "hashivim/vim-terraform",
    ft = { "terraform", "tf", "hcl" },
    config = function()
      vim.g.terraform_align = 1
      vim.g.terraform_fold_sections = 0
      vim.g.terraform_fmt_on_save = 1
    end,
  },

  -- Terraform LSP configuration
  {
    "neovim/nvim-lspconfig",
    optional = true,
    opts = {
      servers = {
        terraformls = {
          filetypes = { "terraform", "tf", "hcl" },
          settings = {
            terraform = {
              validation = {
                enabled = true,
              },
              completion = {
                enabled = true,
              },
            },
          },
        },
      },
    },
  },

  -- Terraform documentation and help
  {
    "juliosueiras/vim-terraform-completion",
    ft = { "terraform", "tf", "hcl" },
    dependencies = { "vim-syntastic/syntastic" },
    config = function()
      vim.g.terraform_completion_keys = 1
      vim.g.terraform_registry_module_completion = 1
    end,
  },

  -- TFLint integration
  {
    "mfussenegger/nvim-lint",
    optional = true,
    opts = function(_, opts)
      opts.linters_by_ft = opts.linters_by_ft or {}
      opts.linters = opts.linters or {}

      -- Add tflint to terraform files
      opts.linters_by_ft.terraform = opts.linters_by_ft.terraform or {}
      table.insert(opts.linters_by_ft.terraform, "tflint")
      opts.linters_by_ft.tf = opts.linters_by_ft.tf or {}
      table.insert(opts.linters_by_ft.tf, "tflint")

      opts.linters.tflint = {
        cmd = "tflint",
        stdin = false,
        args = {
          "--format=json",
          function()
            return vim.fn.expand("%:p")
          end,
        },
        stream = "stdout",
        ignore_exitcode = true,
        parser = function(output)
          local items = {}
          local ok, decoded = pcall(vim.json.decode, output)
          if not ok or not decoded.issues then
            return items
          end

          for _, issue in ipairs(decoded.issues) do
            table.insert(items, {
              lnum = issue.range.start.line - 1,
              col = issue.range.start.column - 1,
              end_lnum = issue.range["end"].line - 1,
              end_col = issue.range["end"].column - 1,
              message = issue.message,
              severity = issue.rule.severity == "error" and vim.diagnostic.severity.ERROR or vim.diagnostic.severity.WARN,
            })
          end
          return items
        end,
      }
    end,
  },

  -- Terraform plan/apply integration
  {
    "ANGkeith/telescope-terraform-doc.nvim",
    dependencies = { "nvim-telescope/telescope.nvim" },
    ft = { "terraform", "tf", "hcl" },
    config = function()
      require('telescope').load_extension('terraform_doc')
    end,
  },

  -- Auto-completion for Terraform modules
  {
    "hrsh7th/nvim-cmp",
    optional = true,
    dependencies = {
      {
        "someone-stole-my-name/yaml-companion.nvim",
        ft = { "terraform", "tf", "hcl" },
      },
    },
  },
}