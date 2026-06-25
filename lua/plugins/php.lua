-- Lit .nvim/docker.lua dans le projet courant.
-- Retourne { service = "php", container_root = "/var/app/lama" } ou nil.
local function get_docker_config()
  local path = vim.fn.getcwd() .. "/.nvim/docker.lua"
  if vim.fn.filereadable(path) == 0 then return nil end
  local ok, cfg = pcall(dofile, path)
  if ok and type(cfg) == "table" then return cfg end
  return nil
end

-- Traduit un chemin absolu hôte vers son équivalent dans le container.
local function to_container_path(host_path, host_root, container_root)
  return container_root .. host_path:sub(#host_root + 1)
end

return {
  -- PHP CS Fixer pour le formatage
  {
    "stevearc/conform.nvim",
    optional = true,
    lazy = true,
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      formatters_by_ft = {
        php = { "php-cs-fixer" },
      },
      formatters = {
        ["php-cs-fixer"] = {
          command = function()
            if get_docker_config() then return "docker" end
            return "php-cs-fixer"
          end,
          args = function(_, ctx)
            local host_root = vim.fn.getcwd()
            local candidates = {
              host_root .. "/.php-cs-fixer.dist.php",
              host_root .. "/.php-cs-fixer.php",
              ctx.dirname .. "/.php-cs-fixer.dist.php",
              ctx.dirname .. "/.php-cs-fixer.php",
            }
            local config_file = "/home/manu/Projects/lama/.php-cs-fixer.dist.php"
            for _, path in ipairs(candidates) do
              if vim.fn.filereadable(path) == 1 then
                config_file = path
                break
              end
            end

            local docker = get_docker_config()
            if docker then
              local c_file   = to_container_path(ctx.filename, host_root, docker.container_root)
              local c_config = to_container_path(config_file,  host_root, docker.container_root)
              return { "compose", "exec", "-T", docker.service, "php-cs-fixer", "fix", "--config=" .. c_config, c_file }
            end

            return { "fix", "--config=" .. config_file, ctx.filename }
          end,
          stdin = false,
        },
      },
      notify_on_error = true,
    },
  },

  -- PHPStan integration via nvim-lint
  {
    "mfussenegger/nvim-lint",
    optional = true,
    opts = {
      linters_by_ft = {
        php = { "phpstan" },
      },
      linters = {
        phpstan = {
          cmd = "phpstan",
          stdin = false,
          args = {
            "analyze",
            "--error-format=json",
            "--no-progress",
            function()
              return vim.fn.expand("%:p")
            end,
          },
          stream = "stdout",
          ignore_exitcode = true,
          parser = function(output)
            local items = {}
            local ok, decoded = pcall(vim.json.decode, output)
            if not ok then
              return items
            end

            for _, file_errors in pairs(decoded.files or {}) do
              for _, error in ipairs(file_errors.messages or {}) do
                table.insert(items, {
                  lnum = error.line - 1,
                  col = 0,
                  message = error.message,
                  severity = vim.diagnostic.severity.ERROR,
                })
              end
            end
            return items
          end,
        },
      },
    },
  },

  -- PHPUnit integration
  {
    "nvim-neotest/neotest",
    optional = true,
    dependencies = {
      "olimorris/neotest-phpunit",
    },
    opts = {
      adapters = {
        ["neotest-phpunit"] = {
          phpunit_cmd = function()
            return "vendor/bin/phpunit"
          end,
          root_files = { "phpunit.xml", "phpunit.xml.dist" },
        },
      },
    },
  },

  -- Breakpoints persistants (survivent aux redémarrages de Neovim)
  {
    "Weissle/persistent-breakpoints.nvim",
    opts = {
      load_breakpoints_event = { "BufReadPost" },
    },
  },

  -- Texte virtuel inline pendant le debug (valeurs des variables)
  {
    "theHamsta/nvim-dap-virtual-text",
    opts = {
      enabled = true,
      commented = true,
    },
  },

  -- Interface graphique pour le debug
  {
    "rcarriga/nvim-dap-ui",
    dependencies = { "nvim-neotest/nvim-nio" },
    keys = {
      { "<leader>du", function()
        local dapui = require("dapui")
        dapui.close({ layout = 2 })
        dapui.close({ layout = 3 })
        dapui.toggle({ layout = 1 })
      end, desc = "DAP: Toggle UI compact" },
      { "<leader>dU", function()
        local dapui = require("dapui")
        dapui.close({ layout = 1 })
        dapui.toggle({ layout = 2 })
        dapui.toggle({ layout = 3 })
      end, desc = "DAP: Toggle UI complet" },
    },
    opts = {
      icons = { expanded = "▾", collapsed = "▸", current_frame = "▸" },
      mappings = {
        expand = { "<CR>", "<2-LeftMouse>" },
        open = "o",
        remove = "d",
        edit = "e",
        repl = "r",
        toggle = "t",
      },
      layouts = {
        -- Layout 1 : compact (scopes + breakpoints)
        {
          elements = {
            { id = "scopes", size = 0.6 },
            { id = "breakpoints", size = 0.4 },
          },
          size = 0.28,
          position = "right",
        },
        -- Layout 2 : complet (scopes + breakpoints + stacks + watches)
        {
          elements = {
            { id = "scopes", size = 0.33 },
            { id = "breakpoints", size = 0.17 },
            { id = "stacks", size = 0.25 },
            { id = "watches", size = 0.25 },
          },
          size = 0.33,
          position = "right",
        },
        -- Layout 3 : console (repl + console en bas)
        {
          elements = {
            { id = "repl", size = 0.45 },
            { id = "console", size = 0.55 },
          },
          size = 0.27,
          position = "bottom",
        },
      },
      floating = {
        max_height = 0.9,
        max_width = 0.5,
        border = "single",
        mappings = { close = { "q", "<Esc>" } },
      },
    },
    config = function(_, opts)
      local dap = require("dap")
      local dapui = require("dapui")
      dapui.setup(opts)

      -- Auto-ouvre l'UI compact au démarrage d'une session
      dap.listeners.after.event_initialized["dapui_config"] = function()
        dapui.open({ layout = 1 })
      end
      dap.listeners.before.event_terminated["dapui_config"] = function()
        dapui.close()
      end
      dap.listeners.before.event_exited["dapui_config"] = function()
        dapui.close()
      end
    end,
  },

  -- XDebug support via nvim-dap
  {
    "mfussenegger/nvim-dap",
    optional = true,
    dependencies = {
      {
        "mason-org/mason.nvim",
        opts = function(_, opts)
          opts.ensure_installed = opts.ensure_installed or {}
          vim.list_extend(opts.ensure_installed, { "php-debug-adapter" })
        end,
      },
    },
    opts = function()
      local dap = require("dap")

      -- Icônes de breakpoints
      vim.fn.sign_define("DapBreakpoint", { text = "●", texthl = "DiagnosticError", linehl = "", numhl = "" })
      vim.fn.sign_define("DapBreakpointCondition", { text = "◆", texthl = "DiagnosticWarn", linehl = "", numhl = "" })
      vim.fn.sign_define("DapBreakpointRejected", { text = "○", texthl = "DiagnosticHint", linehl = "", numhl = "" })
      vim.fn.sign_define("DapLogPoint", { text = "◉", texthl = "DiagnosticInfo", linehl = "", numhl = "" })
      vim.fn.sign_define("DapStopped", { text = "▶", texthl = "DiagnosticWarn", linehl = "DapStoppedLine", numhl = "DapStoppedLine" })
      vim.api.nvim_set_hl(0, "DapStoppedLine", { bg = "#2D3748", default = true })

      -- Adaptateur PHP
      if not dap.adapters.php then
        dap.adapters.php = {
          type = "executable",
          command = "node",
          args = {
            vim.fn.stdpath("data") .. "/mason/packages/php-debug-adapter/extension/out/phpDebug.js",
          },
        }
      end

      -- Config par projet via .nvim/dap.lua, sinon config par défaut
      local function load_project_dap_config()
        local project_config_path = vim.fn.getcwd() .. "/.nvim/dap.lua"
        if vim.fn.filereadable(project_config_path) == 1 then
          local ok, project_config = pcall(dofile, project_config_path)
          if ok and type(project_config) == "function" then
            project_config(dap)
          elseif ok and type(project_config) == "table" then
            for lang, configs in pairs(project_config) do
              dap.configurations[lang] = configs
            end
          end
        else
          dap.configurations.php = {
            {
              type = "php",
              request = "launch",
              name = "Listen for Xdebug",
              port = 9003,
              log = false,
              localSourceRoot = "${workspaceFolder}",
              serverSourceRoot = "${workspaceFolder}",
            },
            {
              type = "php",
              request = "launch",
              name = "Launch currently open script",
              program = "${file}",
              cwd = "${fileDirname}",
              port = 0,
              runtimeArgs = { "-dxdebug.start_with_request=yes" },
              env = {
                XDEBUG_MODE = "debug,develop",
                XDEBUG_CONFIG = "client_port=${port}",
              },
            },
          }
        end
      end

      load_project_dap_config()

      vim.api.nvim_create_autocmd("DirChanged", {
        callback = load_project_dap_config,
      })
    end,
  },

  -- Enhanced PHP syntax and features
  {
    "StanAngeloff/php.vim",
    ft = "php",
    config = function()
      vim.g.php_html_load = 0
      vim.g.php_html_in_heredoc = 0
      vim.g.php_html_in_nowdoc = 0
      vim.g.php_sql_query = 0
      vim.g.php_sql_heredoc = 0
      vim.g.php_sql_nowdoc = 0
    end,
  },

  -- PHP refactoring tools
  {
    "phpactor/phpactor",
    ft = "php",
    build = "composer install --no-dev -o --ignore-platform-req=ext-iconv --ignore-platform-req=ext-mbstring",
    keys = {
      { "<leader>pm", "<cmd>PhpactorContextMenu<cr>", desc = "PHPActor Context Menu" },
      { "<leader>pn", "<cmd>PhpactorClassNew<cr>", desc = "PHPActor New Class" },
      { "<leader>pE", "<cmd>PhpactorClassExpand<cr>", desc = "PHPActor Expand Class" },
      { "<leader>pp", "<cmd>PhpactorCopyFile<cr>", desc = "PHPActor Copy File" },
      { "<leader>pT", "<cmd>PhpactorTransform<cr>", desc = "PHPActor Transform" },
      { "<leader>pi", "<cmd>PhpactorImportClass<cr>", desc = "PHPActor Import Class" },
    },
  },
}
