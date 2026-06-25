-- Terraform-specific keymaps
local map = vim.keymap.set

-- Terraform validation and formatting
map("n", "<leader>tf", "<cmd>lua require('conform').format()<cr>", { desc = "Format with terraform fmt" })
map("n", "<leader>tv", "<cmd>lua require('lint').try_lint('terraform_validate')<cr>", { desc = "Run terraform validate" })
map("n", "<leader>tl", "<cmd>lua require('lint').try_lint('tflint')<cr>", { desc = "Run TFLint" })

-- Terraform plan and apply operations
map("n", "<leader>tp", "<cmd>!terraform plan<cr>", { desc = "Terraform plan" })
map("n", "<leader>ta", "<cmd>!terraform apply<cr>", { desc = "Terraform apply" })
map("n", "<leader>ti", "<cmd>!terraform init<cr>", { desc = "Terraform init" })
map("n", "<leader>td", "<cmd>!terraform destroy<cr>", { desc = "Terraform destroy" })
map("n", "<leader>ts", "<cmd>!terraform show<cr>", { desc = "Terraform show" })
map("n", "<leader>to", "<cmd>!terraform output<cr>", { desc = "Terraform output" })

-- Terraform state management
map("n", "<leader>tsl", "<cmd>!terraform state list<cr>", { desc = "List terraform state" })
map("n", "<leader>tss", "<cmd>!terraform state show ", { desc = "Show terraform state resource" })
map("n", "<leader>tsr", "<cmd>!terraform state rm ", { desc = "Remove from terraform state" })
map("n", "<leader>tsm", "<cmd>!terraform state mv ", { desc = "Move terraform state resource" })

-- Terraform workspace management
map("n", "<leader>twl", "<cmd>!terraform workspace list<cr>", { desc = "List workspaces" })
map("n", "<leader>tws", "<cmd>!terraform workspace select ", { desc = "Select workspace" })
map("n", "<leader>twn", "<cmd>!terraform workspace new ", { desc = "New workspace" })
map("n", "<leader>twd", "<cmd>!terraform workspace delete ", { desc = "Delete workspace" })

-- Terraform import and taint
map("n", "<leader>tim", "<cmd>!terraform import ", { desc = "Terraform import" })
map("n", "<leader>tnt", "<cmd>!terraform taint ", { desc = "Terraform taint" })
map("n", "<leader>tut", "<cmd>!terraform untaint ", { desc = "Terraform untaint" })

-- Terraform documentation and providers
map("n", "<leader>tpv", "<cmd>!terraform providers<cr>", { desc = "Show providers" })
map("n", "<leader>tpu", "<cmd>!terraform init -upgrade<cr>", { desc = "Upgrade providers" })
map("n", "<leader>tdoc", "<cmd>Telescope terraform_doc<cr>", { desc = "Search Terraform docs" })

-- Quick Terraform snippets
map("n", "<leader>tr", 'iresource "" "" {<cr><cr>}<esc>2k$F"a', { desc = "Create resource template" })
map("n", "<leader>tm", 'imodule "" {<cr>source = ""<cr><cr>}<esc>2k$F"a', { desc = "Create module template" })
map("n", "<leader>tda", 'idata "" "" {<cr><cr>}<esc>2k$F"a', { desc = "Create data source template" })
map("n", "<leader>tva", 'ivariable "" {<cr>description = ""<cr>type = <cr>default = <cr>}<esc>3k$F"a', { desc = "Create variable template" })
map("n", "<leader>tou", 'ioutput "" {<cr>description = ""<cr>value = <cr>}<esc>2k$F"a', { desc = "Create output template" })
map("n", "<leader>tlc", 'ilocals {<cr><cr>}<esc>k$a', { desc = "Create locals block" })

-- Terraform console and graph
map("n", "<leader>tc", "<cmd>!terraform console<cr>", { desc = "Open terraform console" })
map("n", "<leader>tg", "<cmd>!terraform graph | dot -Tsvg > graph.svg<cr>", { desc = "Generate dependency graph" })

-- Cloud provider specific shortcuts
-- AWS
map("n", "<leader>taws", 'iresource "aws_" "" {<cr><cr>}<esc>2k$F_a', { desc = "AWS resource template" })
map("n", "<leader>tawsd", 'idata "aws_" "" {<cr><cr>}<esc>2k$F_a', { desc = "AWS data source template" })

-- Azure
map("n", "<leader>taz", 'iresource "azurerm_" "" {<cr><cr>}<esc>2k$F_a', { desc = "Azure resource template" })
map("n", "<leader>tazd", 'idata "azurerm_" "" {<cr><cr>}<esc>2k$F_a', { desc = "Azure data source template" })

-- Google Cloud
map("n", "<leader>tgcp", 'iresource "google_" "" {<cr><cr>}<esc>2k$F_a', { desc = "GCP resource template" })
map("n", "<leader>tgcpd", 'idata "google_" "" {<cr><cr>}<esc>2k$F_a', { desc = "GCP data source template" })

-- Terraform refresh and plan with specific options
map("n", "<leader>tpr", "<cmd>!terraform plan -refresh-only<cr>", { desc = "Terraform plan refresh-only" })
map("n", "<leader>tpd", "<cmd>!terraform plan -destroy<cr>", { desc = "Terraform plan destroy" })
map("n", "<leader>tpt", "<cmd>!terraform plan -target=", { desc = "Terraform plan target" })
map("n", "<leader>tat", "<cmd>!terraform apply -target=", { desc = "Terraform apply target" })