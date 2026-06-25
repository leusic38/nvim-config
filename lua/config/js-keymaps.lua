-- JavaScript/TypeScript/Vue keymaps (buffer-local — chargés via FileType dans autocmds.lua)
-- Note: les keymaps TypeScript Tools (<leader>jl*) et package-info (<leader>jp*)
-- sont déjà définis dans lua/plugins/javascript.lua via keys = {} — pas de doublons ici.
local map = vim.keymap.set
local buf = { buffer = 0 }

-- Tests avec neotest (Jest / Vitest)
map("n", "<leader>jta", "<cmd>lua require('neotest').run.run(vim.fn.expand('%'))<cr>", vim.tbl_extend("force", buf, { desc = "JS: Run all tests in file" }))
map("n", "<leader>jtn", "<cmd>lua require('neotest').run.run()<cr>", vim.tbl_extend("force", buf, { desc = "JS: Run nearest test" }))
map("n", "<leader>jts", "<cmd>lua require('neotest').summary.toggle()<cr>", vim.tbl_extend("force", buf, { desc = "JS: Toggle test summary" }))
map("n", "<leader>jto", "<cmd>lua require('neotest').output.open({ enter = true })<cr>", vim.tbl_extend("force", buf, { desc = "JS: Open test output" }))
map("n", "<leader>jtw", "<cmd>lua require('neotest').watch.toggle(vim.fn.expand('%'))<cr>", vim.tbl_extend("force", buf, { desc = "JS: Watch tests" }))

-- Debugging Node.js
map("n", "<leader>jdb", "<cmd>lua require('dap').toggle_breakpoint()<cr>", vim.tbl_extend("force", buf, { desc = "JS: Toggle breakpoint" }))
map("n", "<leader>jdc", "<cmd>lua require('dap').continue()<cr>", vim.tbl_extend("force", buf, { desc = "JS: Continue" }))
map("n", "<leader>jds", "<cmd>lua require('dap').step_over()<cr>", vim.tbl_extend("force", buf, { desc = "JS: Step over" }))
map("n", "<leader>jdi", "<cmd>lua require('dap').step_into()<cr>", vim.tbl_extend("force", buf, { desc = "JS: Step into" }))
map("n", "<leader>jdo", "<cmd>lua require('dap').step_out()<cr>", vim.tbl_extend("force", buf, { desc = "JS: Step out" }))
map("n", "<leader>jdr", "<cmd>lua require('dap').repl.open()<cr>", vim.tbl_extend("force", buf, { desc = "JS: Open REPL" }))
map("n", "<leader>jdl", "<cmd>lua require('dap').run_last()<cr>", vim.tbl_extend("force", buf, { desc = "JS: Run last" }))

-- ESLint
map("n", "<leader>jle", "<cmd>EslintFixAll<cr>", vim.tbl_extend("force", buf, { desc = "JS: Fix all ESLint issues" }))

-- Vue spécifique
map("n", "<leader>vc", "<cmd>lua vim.lsp.buf.code_action()<cr>", vim.tbl_extend("force", buf, { desc = "Vue: Code actions" }))
map("n", "<leader>vr", "<cmd>lua vim.lsp.buf.rename()<cr>", vim.tbl_extend("force", buf, { desc = "Vue: Rename" }))

-- Snippets et templates
map("n", "<leader>jc", "i// Component template<cr>export default {<cr>  name: '',<cr>  data() {<cr>    return {<cr>      <cr>    }<cr>  },<cr>  methods: {<cr>    <cr>  }<cr>}<esc>", vim.tbl_extend("force", buf, { desc = "JS: Component template" }))
map("n", "<leader>jf", "i// Function template<cr>const functionName = () => {<cr>  <cr>}<esc>", vim.tbl_extend("force", buf, { desc = "JS: Function template" }))
map("n", "<leader>ja", "i// Async function template<cr>const asyncFunction = async () => {<cr>  try {<cr>    <cr>  } catch (error) {<cr>    console.error(error)<cr>  }<cr>}<esc>", vim.tbl_extend("force", buf, { desc = "JS: Async function template" }))
map("n", "<leader>jtc", "i// TypeScript class template<cr>class ClassName {<cr>  private property: string;<cr><cr>  constructor(property: string) {<cr>    this.property = property;<cr>  }<cr><cr>  public method(): void {<cr>    <cr>  }<cr>}<esc>", vim.tbl_extend("force", buf, { desc = "JS: TypeScript class template" }))
map("n", "<leader>jti", "i// TypeScript interface template<cr>interface InterfaceName {<cr>  property: string;<cr>  method(): void;<cr>}<esc>", vim.tbl_extend("force", buf, { desc = "JS: TypeScript interface template" }))

-- Templates Vue
map("n", "<leader>vs", "i<template><cr>  <div><cr>    <cr>  </div><cr></template><cr><cr><script><cr>export default {<cr>  name: 'ComponentName',<cr>  data() {<cr>    return {<cr>      <cr>    }<cr>  }<cr>}<cr></script><cr><cr><style scoped><cr><cr></style><esc>", vim.tbl_extend("force", buf, { desc = "Vue: SFC template" }))
map("n", "<leader>v3", "i<template><cr>  <div><cr>    <cr>  </div><cr></template><cr><cr><script setup lang=\"ts\"><cr>import { ref } from 'vue'<cr><cr>const count = ref(0)<cr></script><cr><cr><style scoped><cr><cr></style><esc>", vim.tbl_extend("force", buf, { desc = "Vue: Composition API template" }))

-- npm commands
map("n", "<leader>jni", ":!npm install<cr>", vim.tbl_extend("force", buf, { desc = "JS: npm install" }))
map("n", "<leader>jnr", ":!npm run ", vim.tbl_extend("force", buf, { desc = "JS: npm run" }))
map("n", "<leader>jnt", ":!npm test<cr>", vim.tbl_extend("force", buf, { desc = "JS: npm test" }))
map("n", "<leader>jnb", ":!npm run build<cr>", vim.tbl_extend("force", buf, { desc = "JS: npm run build" }))
map("n", "<leader>jnd", ":!npm run dev<cr>", vim.tbl_extend("force", buf, { desc = "JS: npm run dev" }))

-- yarn commands
map("n", "<leader>yi", ":!yarn install<cr>", vim.tbl_extend("force", buf, { desc = "JS: yarn install" }))
map("n", "<leader>yr", ":!yarn ", vim.tbl_extend("force", buf, { desc = "JS: yarn run" }))
map("n", "<leader>yt", ":!yarn test<cr>", vim.tbl_extend("force", buf, { desc = "JS: yarn test" }))
map("n", "<leader>yb", ":!yarn build<cr>", vim.tbl_extend("force", buf, { desc = "JS: yarn build" }))
map("n", "<leader>yd", ":!yarn dev<cr>", vim.tbl_extend("force", buf, { desc = "JS: yarn dev" }))

-- Console (buffer-local — n'écrase plus <leader>c* de LazyVim dans les autres buffers)
map("n", "<leader>jcl", "iconsole.log()<esc>", vim.tbl_extend("force", buf, { desc = "JS: console.log" }))
map("n", "<leader>jce", "iconsole.error()<esc>", vim.tbl_extend("force", buf, { desc = "JS: console.error" }))
map("n", "<leader>jcw", "iconsole.warn()<esc>", vim.tbl_extend("force", buf, { desc = "JS: console.warn" }))
map("n", "<leader>jci", "iconsole.info()<esc>", vim.tbl_extend("force", buf, { desc = "JS: console.info" }))
