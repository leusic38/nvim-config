-- Add option in config

local options = {
	clipboard = "unnamedplus", -- allows neovim to access the system clipboard
  cursorline = true,
	splitbelow = true, -- horizontal split go bellow current window
	splitright = true, -- vertical split go right of current window,
	expandtab = true, --convert tab to space
	shiftwidth = 2,   -- number of identation width
	tabstop = 2,
  number = true,
  relativenumber = false,
}

vim.opt.shortmess:append "c"

for k, v in pairs(options) do
	vim.opt[k] = v
end
