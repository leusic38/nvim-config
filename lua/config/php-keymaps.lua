-- PHP-specific keymaps (buffer-local — chargés via FileType php dans autocmds.lua)
local map = vim.keymap.set
local buf = { buffer = 0 }

-- PHPUnit testing
map("n", "<leader>pta", "<cmd>lua require('neotest').run.run(vim.fn.expand('%'))<cr>", vim.tbl_extend("force", buf, { desc = "PHP: Run all tests in file" }))
map("n", "<leader>ptn", "<cmd>lua require('neotest').run.run()<cr>", vim.tbl_extend("force", buf, { desc = "PHP: Run nearest test" }))
map("n", "<leader>pts", "<cmd>lua require('neotest').summary.toggle()<cr>", vim.tbl_extend("force", buf, { desc = "PHP: Toggle test summary" }))
map("n", "<leader>pto", "<cmd>lua require('neotest').output.open({ enter = true })<cr>", vim.tbl_extend("force", buf, { desc = "PHP: Show test output" }))

-- XDebug debugging (breakpoints persistants via persistent-breakpoints.nvim)
map("n", "<leader>pdb", "<cmd>lua require('persistent-breakpoints.api').toggle_breakpoint()<cr>", vim.tbl_extend("force", buf, { desc = "PHP: Toggle breakpoint" }))
map("n", "<leader>pdB", "<cmd>lua require('persistent-breakpoints.api').set_conditional_breakpoint()<cr>", vim.tbl_extend("force", buf, { desc = "PHP: Conditional breakpoint" }))
map("n", "<leader>pdc", "<cmd>lua require('dap').continue()<cr>", vim.tbl_extend("force", buf, { desc = "PHP: Continue debugging" }))
map("n", "<leader>pds", "<cmd>lua require('dap').step_over()<cr>", vim.tbl_extend("force", buf, { desc = "PHP: Step over" }))
map("n", "<leader>pdi", "<cmd>lua require('dap').step_into()<cr>", vim.tbl_extend("force", buf, { desc = "PHP: Step into" }))
map("n", "<leader>pdo", "<cmd>lua require('dap').step_out()<cr>", vim.tbl_extend("force", buf, { desc = "PHP: Step out" }))
map("n", "<leader>pdr", "<cmd>lua require('dap').repl.open()<cr>", vim.tbl_extend("force", buf, { desc = "PHP: Open REPL" }))
map("n", "<leader>pdt", "<cmd>lua require('dap').terminate()<cr>", vim.tbl_extend("force", buf, { desc = "PHP: Terminate debugging" }))

-- PHP-specific formatting and linting
map("n", "<leader>plf", "<cmd>lua vim.lsp.buf.format()<cr>", vim.tbl_extend("force", buf, { desc = "PHP: Format with LSP" }))
map("n", "<leader>plc", "<cmd>lua require('conform').format()<cr>", vim.tbl_extend("force", buf, { desc = "PHP: Format with CS Fixer" }))
map("n", "<leader>pll", "<cmd>lua require('lint').try_lint()<cr>", vim.tbl_extend("force", buf, { desc = "PHP: Run PHPStan" }))

-- Quick PHP snippets
map("n", "<leader>pv", "i<?php<cr><cr>declare(strict_types=1);<cr><cr>", vim.tbl_extend("force", buf, { desc = "PHP: Insert header with strict types" }))
map("n", "<leader>pc", "iclass <cr>{<cr><cr>}<esc>2k$F a", vim.tbl_extend("force", buf, { desc = "PHP: Class template" }))
map("n", "<leader>pf", "ipublic function ()<cr>{<cr><cr>}<esc>2k$F)i", vim.tbl_extend("force", buf, { desc = "PHP: Function template" }))

-- Symfony Console shortcuts (buffer-local pour éviter d'écraser <leader>s* de LazyVim)
map("n", "<leader>Sc", "<cmd>!php bin/console ", vim.tbl_extend("force", buf, { desc = "Symfony: Console command" }))
map("n", "<leader>Sm", "<cmd>!php bin/console make:", vim.tbl_extend("force", buf, { desc = "Symfony: Make command" }))
map("n", "<leader>Sd", "<cmd>!php bin/console doctrine:", vim.tbl_extend("force", buf, { desc = "Symfony: Doctrine command" }))
map("n", "<leader>Sr", "<cmd>!php bin/console debug:router<cr>", vim.tbl_extend("force", buf, { desc = "Symfony: Debug routes" }))
map("n", "<leader>Ss", "<cmd>!php bin/console debug:container<cr>", vim.tbl_extend("force", buf, { desc = "Symfony: Debug services" }))
map("n", "<leader>Se", "<cmd>!php bin/console debug:config<cr>", vim.tbl_extend("force", buf, { desc = "Symfony: Debug config" }))

-- Composer shortcuts (buffer-local pour éviter d'écraser <leader>c* de LazyVim)
map("n", "<leader>Cu", "<cmd>!composer update<cr>", vim.tbl_extend("force", buf, { desc = "Composer: update" }))
map("n", "<leader>Ci", "<cmd>!composer install<cr>", vim.tbl_extend("force", buf, { desc = "Composer: install" }))
map("n", "<leader>Cd", "<cmd>!composer dump-autoload<cr>", vim.tbl_extend("force", buf, { desc = "Composer: dump-autoload" }))
map("n", "<leader>Cr", "<cmd>!composer require ", vim.tbl_extend("force", buf, { desc = "Composer: require" }))

-- Symfony-specific snippets
map("n", "<leader>pe", "i#[Entity]<cr>class <cr>{<cr><cr>}<esc>2k$F a", vim.tbl_extend("force", buf, { desc = "PHP: Doctrine Entity template" }))
map("n", "<leader>pr", "iclass Repository extends ServiceEntityRepository<cr>{<cr><cr>}<esc>2k$FRa", vim.tbl_extend("force", buf, { desc = "PHP: Repository template" }))
map("n", "<leader>ps", "i#[Service]<cr>class Service<cr>{<cr><cr>}<esc>2k$FSa", vim.tbl_extend("force", buf, { desc = "PHP: Service template" }))
