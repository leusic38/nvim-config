-- Bootstrap runtimepath for headless plenary tests.
-- Run from the nvim config root:
--   nvim --headless --noplugin -u tests/minimal_init.lua \
--     -c "PlenaryBustedDirectory tests/ {minimal_init='tests/minimal_init.lua'}"
local data = vim.fn.stdpath("data")
vim.opt.rtp:prepend(data .. "/lazy/plenary.nvim")
vim.opt.rtp:prepend(vim.fn.getcwd()) -- exposes ./lua/nvimtrainer/*
vim.cmd("runtime plugin/plenary.vim")
