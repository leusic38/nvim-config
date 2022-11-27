local M = {}

function M.setup()
  require("nvim-tree").setup {
    disable_netrw = true,
    hijack_netrw = true,
    view = {
      number = true,
      relativenumber = true,
      side = "left",
    },
    update_cwd = true,
    open_on_setup = true,
    open_on_setup_file = true,
    actions = {
      open_file = {
        resize_window = true,
      },
    },
    update_focused_file = {
      enable = true,
      update_cwd = true,
    },
    filters = {
      dotfiles = false,
    },
    diagnostics = {
      enable = true,
    },
  }
end

return M
