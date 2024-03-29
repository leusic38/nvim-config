local M = {}

local utils = require('utils')

local keymappings = {
  insert_mode = {
    ["jk"] = {"<Esc>",{noremap = true, silent = false}},
    ["<A-k>"] = {"<Esc>:m .-2<CR>==gi"},
    ["<A-j>"] = {"<Esc>:m .+1<CR>==gi"},
   -- [","] = ",<c-g>u",
   -- ["."] = ".<c-g>u",
   -- ["!"] = "!<c-g>u",
   -- ["?"] = "?<c-g>u",
   -- ["<M-o>"] = "<C-O>o",
   -- ["<M-O>"] = "<C-O>O",
  },
  normal_mode = {
    ["<C-n>"] = {":NvimTreeToggle<CR>"},
    ["<C-l>"] = {"<C-w>l"},
    ["<C-h>"] = {"<C-w>h"},
    ["<C-k>"] = {"<C-w>k"},
    ["<C-j>"] = {"<C-w>j"},
    ["<C-w><C-o>"] = {"<Cmd>MaximizerToggle!<CR>"},
    ["<C-left>"] = {":vertical resize -2<CR>"},
    ["<C-right>"] = {":vertical resize +2<CR>"},
    ["<C-up>"] = {":resize +2<CR>"},
    ["<C-down>"] = {":resize -2<CR>"},
    ["<A-j>"] = {":m+1<CR>=="},
    ["<A-k>"] = {":m-2<CR>=="},
    ["Y"] = {"y$"},
    ["<S-h>"] = {"<Cmd>bp<Cr>"},
    ["<S-l>"] = {"<Cmd>bn<Cr>"},
    ["n"] = {"nzzzv"},
    ["N"] = {"Nzzzv"},
   -- ["J"] = "mzJ`z",
   -- ["<expr> j"] = "(v:count > 1 ? \"m'\" . v:count : '') . 'j'",
   -- ["<expr> k"] = "(v:count > 1 ? \"m'\" . v:count : '') . 'k'",
   -- ["gx"] = { "<Plug>(openbrowser-smart-search)", { noremap = false, silent = false } },
   -- [",h"] = "<Cmd>wincmd h<Cr>",
   -- [",j"] = "<Cmd>wincmd j<Cr>",
   -- [",l"] = "<Cmd>wincmd l<Cr>",
   -- [",k"] = "<Cmd>wincmd k<Cr>",
   -- [",s"] = "<Cmd>split<Cr>",
   -- ["g,"] = "g,zvzz",
   -- ["g;"] = "g;zvzz",
    -- [";"] = ":"
  },
  visual_mode = {
    ["<"] = {"<gv"},
    [">"] = {">gv"},
    ["<A-j>"] = {":m '>+1<CR>gv=gv"},
    ["<A-k>"] = {":m '<-2<CR>gv=gv"},
    ["<leader>y"] = {"\"+y"},
  --  ["gx"] = { "<Plug>(openbrowser-smart-search)", { noremap = false, silent = false } },
  --  -- [";"] = ":"
  },
  visual_block_mode = {
    ["<"] = {"<gv"},
    [">"] = {">gv"},
    ["<A-j>"] = {":m '>+1<CR>gv=gv"},
    ["<A-k>"] = {":m '<-2<CR>gv=gv"},
    ["<leader>y"] = {"\"+y"},
  --  ["gx"] = { "<Plug>(openbrowser-smart-search)", { noremap = false, silent = false } },
  --  -- [";"] = ":"
  },
  --term_mode = {
  --  ["<C-w><C-o>"] = {"<C-\\><C-n> :MaximizerToggle!<CR>"},
  --  ["<C-h>"] = {"<C-\\><C-n><C-w>h"},
  --  ["<C-j>"] = {"<C-\\><C-n><C-w>j"},
  --  ["<C-k>"] = {"<C-\\><C-n><C-w>k"},
  --  ["<C-l>"] = {"<C-\\><C-n><C-w>l"},
  --  ["jk"] = {"<C-\\><C-n>"},
  --},
  --command_mode = {
    --["<C-j>"] = {
    --  'pumvisible() ? "\\<C-n>" : "\\<C-j>"',
    --  { expr = true, noremap = true },
    --},
    --["<C-k>"] = {
    --  'pumvisible() ? "\\<C-p>" : "\\<C-k>"',
    --  { expr = true, noremap = true },
    --},
    --["w!!"] = "execute 'silent! write !sudo tee % >/dev/null' <bar> edit!",
    --["%%"] = { "getcmdtype() == ':' ? expand('%:p:h').'/' : '%%'", { expr = true, noremap = true } },
    --["%H"] = { "<C-R>=expand('%:h:p') . std#path#separator()<CR>", { expr = false, noremap = true } },
    --["%T"] = { "<C-R>=expand('%:t')<CR>", { expr = false, noremap = true } },
    --["%P"] = { "<C-R>=expand('%:p')<CR>", { expr = false, noremap = true } },
  --},
}

function M.setup()
  for mode, mapping in pairs(keymappings) do
    utils.map(mode, mapping)
  end
end

M.setup()
