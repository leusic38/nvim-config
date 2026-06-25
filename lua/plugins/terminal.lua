return {
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    config = function()
      require("toggleterm").setup({
        -- Taille du terminal
        size = function(term)
          if term.direction == "horizontal" then
            return 15
          elseif term.direction == "vertical" then
            return vim.o.columns * 0.4
          else
            return 20
          end
        end,
        -- Terminal flottant par défaut
        direction = "float",
        -- Options pour le terminal flottant
        float_opts = {
          border = "curved", -- 'single' | 'double' | 'shadow' | 'curved'
          width = math.floor(vim.o.columns * 0.8),
          height = math.floor(vim.o.lines * 0.8),
          winblend = 0,
        },
        -- Garder le terminal ouvert après la fermeture de la fenêtre
        persist_mode = true,
        persist_size = true,
        -- Commencer en mode insertion
        start_in_insert = true,
        -- Fermer le terminal au lieu de le cacher avec ESC
        on_open = function(term)
          vim.cmd("startinsert!")
          -- Keymaps spécifiques au terminal
          vim.api.nvim_buf_set_keymap(
            term.bufnr,
            "t",
            "<Esc>",
            "<C-\\><C-n>:close<CR>",
            { noremap = true, silent = true }
          )
          -- Passer en mode normal (pour utiliser <leader> et keymaps nvim) sans fermer
          vim.api.nvim_buf_set_keymap(term.bufnr, "t", "<C-Space>", "<C-\\><C-n>", { silent = true })
          vim.api.nvim_buf_set_keymap(term.bufnr, "t", "<C-h>", "<C-\\><C-n><C-w>h", { silent = true })
          vim.api.nvim_buf_set_keymap(term.bufnr, "t", "<C-j>", "<C-\\><C-n><C-w>j", { silent = true })
          vim.api.nvim_buf_set_keymap(term.bufnr, "t", "<C-k>", "<C-\\><C-n><C-w>k", { silent = true })
          vim.api.nvim_buf_set_keymap(term.bufnr, "t", "<C-l>", "<C-\\><C-n><C-w>l", { silent = true })
        end,
        -- Mode ombre
        shade_terminals = true,
      })

      -- Keymaps globaux
      local keymap = vim.keymap.set

      -- <C-\> pour toggle le terminal flottant (comme la recherche)
      keymap("n", "<C-\\>", "<cmd>ToggleTerm direction=float<cr>", { desc = "Toggle floating terminal" })
      keymap("t", "<C-\\>", "<cmd>ToggleTerm direction=float<cr>", { desc = "Toggle floating terminal" })

      -- <leader>tf pour terminal flottant
      keymap("n", "<leader>tf", "<cmd>ToggleTerm direction=float<cr>", { desc = "Float Terminal" })
      -- <leader>th pour terminal horizontal
      keymap("n", "<leader>th", "<cmd>ToggleTerm direction=horizontal<cr>", { desc = "Horizontal Terminal" })
      -- <leader>tv pour terminal vertical
      keymap("n", "<leader>tv", "<cmd>ToggleTerm direction=vertical<cr>", { desc = "Vertical Terminal" })
    end,
  },
}
