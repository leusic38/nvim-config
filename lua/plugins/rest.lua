return {
  "mistweaverco/kulala.nvim",
  dependencies = { "nvim-lua/plenary.nvim" },
  ft = "http",
  keys = {
    { "<leader>rs", function() require("kulala").run() end, mode = { "n", "v" }, desc = "REST: Send request" },
    { "<leader>rr", function() require("kulala").replay() end, desc = "REST: Replay last request" },
    { "<leader>rc", function() require("kulala").copy() end, desc = "REST: Copy as cURL" },
    { "<leader>re", function()
      require("kulala").set_selected_env()
      vim.schedule(function() vim.cmd("stopinsert") end)
    end, desc = "REST: Switch environment" },
    { "<leader>rb", function() require("kulala").scratchpad() end, desc = "REST: Open scratchpad" },
  },
  config = function()
    local default_opts = {
      default_env = "local",
      default_view = "headers_body",
      vscode_rest_client_environmentvars = true,
      show_icons = "on_request",
      winbar = true,
      default_winbar_panes = { "body", "headers", "headers_body", "verbose" },
    }

    -- Charge la config kulala du projet si elle existe
    local function load_project_config()
      local path = vim.fn.getcwd() .. "/.nvim/kulala.lua"
      if vim.fn.filereadable(path) == 1 then
        local ok, project_config = pcall(dofile, path)
        if ok and type(project_config) == "table" then
          return vim.tbl_deep_extend("force", default_opts, project_config)
        end
      end
      return default_opts
    end

    require("kulala").setup(load_project_config())

    vim.api.nvim_create_autocmd("DirChanged", {
      callback = function()
        require("kulala").setup(load_project_config())
      end,
    })
  end,
}
