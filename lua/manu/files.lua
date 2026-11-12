-- Explorateur : oil.nvim (un dossier s'édite comme un buffer : renommer, créer, supprimer).
-- Remplace netrw et neo-tree. Config reprise de l'ancienne lua/plugins/explorer.lua.

-- Oil remplace netrw : on empêche netrw de se charger.
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

vim.pack.add({ "https://github.com/stevearc/oil.nvim" }, { confirm = false })

local oil = require("oil")
oil.setup({
  default_file_explorer = true,
  columns = { "icon" },
  keymaps = {
    ["<C-h>"] = false, -- laissé à la navigation entre fenêtres
    ["<A-v>"] = { "actions.select", opts = { vertical = true }, desc = "Ouvrir dans un découpage vertical" },
    ["<A-h>"] = { "actions.select", opts = { horizontal = true }, desc = "Ouvrir dans un découpage horizontal" },
  },
  float = { border = "rounded", padding = 2, max_width = 90, max_height = 30 },
  view_options = {
    show_hidden = true,
    natural_order = true,
    is_always_hidden = function(name)
      return name == ".git"
    end,
  },
})

vim.keymap.set("n", "-", "<cmd>Oil<cr>", { desc = "Dossier parent (Oil)" })
vim.keymap.set("n", "<leader>e", function()
  oil.toggle_float()
end, { desc = "Dossier parent (Oil flottant)" })
