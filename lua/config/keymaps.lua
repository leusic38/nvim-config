-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
local keymap = vim.keymap.set

-- Paste over currently selected text without yanking it
keymap("v", "p", '"_dp')

keymap("n", "<CR>", "o<ESC>", { desc = "Add line above and move cursor on" })
keymap("n", "<S-Enter>", "O<ESC>", { desc = "Add line before and move cursor on" })
keymap("n", "<C-a>", "gg<S-v>G", { desc = "Select All" })

-- Create new file with name prompt
keymap("n", "<leader>fn", function()
  vim.ui.input({ prompt = "New file name: " }, function(input)
    if input and input ~= "" then
      vim.cmd("edit " .. input)
    end
  end)
end, { desc = "New file" })

-- Copy current file name / path to system clipboard
local function copy_path(mod)
  local p = vim.fn.expand("%:" .. mod)
  if p == "" then
    vim.notify("Aucun fichier", vim.log.levels.WARN)
    return
  end
  vim.fn.setreg("+", p)
  vim.notify("Copié: " .. p)
end
keymap("n", "<leader>yn", function() copy_path("t") end, { desc = "Copy file name" })
keymap("n", "<leader>yp", function() copy_path(".") end, { desc = "Copy relative path" })
keymap("n", "<leader>yP", function() copy_path("p") end, { desc = "Copy absolute path" })

-- Spell checking navigation
keymap("n", "]s", "]s", { desc = "Next spelling error" })
keymap("n", "[s", "[s", { desc = "Previous spelling error" })
keymap("n", "z=", "z=", { desc = "Spelling suggestions" })
keymap("n", "zg", "zg", { desc = "Add word to dictionary" })
keymap("n", "zw", "zw", { desc = "Mark word as incorrect" })
keymap("n", "zug", "zug", { desc = "Remove word from dictionary" })

-- Show keymaps documentation in floating window
keymap("n", "<leader>K", function()
  local keymaps_path = vim.fn.stdpath("config") .. "/KEYMAPS.md"

  -- Load file into a scratch buffer
  local buf = vim.api.nvim_create_buf(false, true)
  local lines = vim.fn.readfile(keymaps_path)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].filetype = "markdown"
  vim.bo[buf].readonly = true
  vim.bo[buf].modifiable = false
  vim.bo[buf].bufhidden = "wipe"

  -- Floating window dimensions
  local width = math.floor(vim.o.columns * 0.85)
  local height = math.floor(vim.o.lines * 0.85)
  local row = math.floor((vim.o.lines - height) / 2)
  local col = math.floor((vim.o.columns - width) / 2)

  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = width,
    height = height,
    row = row,
    col = col,
    style = "minimal",
    border = "rounded",
    title = " ⌨  Raccourcis Clavier ",
    title_pos = "center",
  })

  vim.wo[win].wrap = false
  vim.wo[win].cursorline = true
  vim.wo[win].conceallevel = 2

  -- Close with q or Esc
  for _, key in ipairs({ "q", "<Esc>" }) do
    vim.api.nvim_buf_set_keymap(buf, "n", key, "<cmd>close<cr>", { noremap = true, silent = true })
  end
end, { desc = "Show keymaps documentation" })
