# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Guidelines for Claude Code

### Keybinding Management Rules

**CRITICAL**: When working with keybindings in this repository, you MUST follow these rules:

1. **Single Source of Truth**: All keybindings MUST be documented in `KEYMAPS.md` - this is the authoritative reference
2. **Check for Conflicts**: Before adding a new keybinding:
   - Read `KEYMAPS.md` to check for existing bindings
   - Search for the keymap in language-specific files (`lua/config/*-keymaps.lua`)
   - Verify no conflicts with LazyVim defaults
3. **Update Documentation**: When adding/modifying keybindings:
   - First update the relevant keymap file (`lua/config/*.lua` or `lua/plugins/*.lua`)
   - Then immediately update `KEYMAPS.md` with the new binding
   - Add it to the appropriate section based on functionality
4. **Never Duplicate**: Do NOT list detailed keybindings in `CLAUDE.md` - only reference `KEYMAPS.md`
5. **Conflict Resolution**: If a keymap conflict is detected:
   - Alert the user immediately
   - Suggest alternative keybindings
   - Document the conflict and resolution in `KEYMAPS.md`

### Verification Checklist for New Keybindings

Before confirming a new keybinding implementation:
- [ ] Checked `KEYMAPS.md` for conflicts
- [ ] Verified against language-specific keymap files
- [ ] Updated the implementation file
- [ ] Updated `KEYMAPS.md` documentation
- [ ] Tested that the binding works as expected

## Architecture Overview

This is a personal Neovim configuration built on top of LazyVim with specialized PHP development tools and AI integration. The configuration follows LazyVim's modular plugin system with custom extensions.

### Configuration Structure

- **LazyVim Base**: Built on LazyVim starter template with standard conventions
- **Plugin System**: Uses lazy.nvim for plugin management with spec-based configuration
- **Custom Extensions**: Six main areas of customization:
  - PHP development tooling (lua/plugins/php.lua)
  - JavaScript/TypeScript/Vue development (lua/plugins/javascript.lua)
  - Terraform infrastructure as code (lua/plugins/terraform.lua)
  - Kotlin development (lua/plugins/kotlin.lua)
  - AI integration with Claude (lua/plugins/ai.lua)
  - File explorer replacement (lua/plugins/explorer.lua)
  - Persistent floating terminal (lua/plugins/terminal.lua)

### Key Components

**PHP Development Stack**:
- Intelephense LSP (configured as primary PHP LSP via `vim.g.lazyvim_php_lsp = "intelephense"`)
- PHP CS Fixer integration via conform.nvim with hardcoded config path `/home/manu/Projects/lama/.php-cs-fixer.dist.php`
- PHPStan analysis via nvim-lint with JSON output parsing
- PHPUnit testing via neotest-phpunit adapter
- XDebug debugging via nvim-dap with Node.js-based php-debug-adapter
- PHPActor for advanced refactoring and class generation

**JavaScript/TypeScript/Vue Development Stack**:
- ESLint integration via nvim-lint for code quality
- Prettier formatting via conform.nvim
- TypeScript LSP with enhanced tools (TSTools)
- Jest/Vitest testing via neotest adapters
- Node.js debugging via nvim-dap
- Package.json management with package-info.nvim
- Vue.js development with specialized LSP support

**Terraform Infrastructure Stack**:
- Terraform LSP (terraformls) for syntax and validation
- terraform fmt integration via conform.nvim
- terraform validate and TFLint via nvim-lint with JSON parsing
- Enhanced syntax highlighting via vim-terraform
- Terraform documentation via telescope-terraform-doc
- Module completion and registry integration

**Kotlin Development Stack**:
- Kotlin Language Server for syntax, completion, and analysis
- ktlint formatting and linting via conform.nvim and nvim-lint
- JUnit testing via neotest-junit adapter
- Java Debug Adapter for Kotlin debugging (attach and launch modes)
- Gradle and Maven build tool integration
- Spring Boot development support
- Code templates for classes, data classes, sealed classes, interfaces, etc.

**AI Integration**:
- claude-ai.nvim as primary AI interface using Claude Code CLI
- Connects to Claude via normal connection (no API key required)
- Custom PHP-expert prompt template for specialized PHP assistance
- Works with the official Claude Code CLI tool

**File Management**:
- Oil.nvim replaces neo-tree as default file explorer
- Custom keymaps for split operations (`<Alt-v>`, `<Alt-h>`)
- Shows hidden files but always hides .git directory

**Terminal Integration**:
- toggleterm.nvim provides persistent floating terminal
- Terminal content persists when closed (history and output maintained)
- Floating window style matching Telescope search UI
- Multiple terminal orientations (floating, horizontal, vertical)
- Terminal starts in insert mode automatically
- Navigation between windows using standard Ctrl-hjkl

## Key Commands and Usage

### PHP Development
- PHP CS Fixer: Uses hardcoded config at `/home/manu/Projects/lama/.php-cs-fixer.dist.php`
- PHPStan: Expects `phpstan` binary in PATH with JSON format output
- PHPUnit: Looks for `vendor/bin/phpunit` and standard phpunit.xml config files
- XDebug: Configured for port 9003 with local/server source root matching

## Keybindings Reference

**IMPORTANT**: All keybindings are documented in the dedicated **KEYMAPS.md** file. See that file for the complete, authoritative list of all keyboard shortcuts.

### Quick Reference
- **Keymaps File**: `/KEYMAPS.md` - Complete keyboard shortcuts documentation
- **Organization**: Keymaps are grouped by functionality (Navigation, Editing, Language-specific, etc.)
- **Language-Specific**: PHP, JavaScript/TypeScript, Kotlin, and Terraform have dedicated keymap files:
  - `lua/config/php-keymaps.lua` - PHP development shortcuts
  - `lua/config/js-keymaps.lua` - JavaScript/TypeScript/Vue shortcuts
  - `lua/config/kotlin-keymaps.lua` - Kotlin development shortcuts
  - `lua/config/terraform-keymaps.lua` - Terraform infrastructure shortcuts

### Most Essential Shortcuts
- `<leader><space>` - Find files (most used)
- `<leader>/` - Global search
- `<C-\>` - Toggle floating terminal (persistent)
- `<leader>aa` - Open Claude AI
- `<leader>ca` - Code actions

Auto-linting and auto-formatting on save are enabled for all supported file types.

**Note**: When adding new keybindings, always update KEYMAPS.md to maintain a single source of truth and check for conflicts.

## Dependencies and Environment Setup

### Global Requirements
- Requires Claude Code CLI for AI features
- Node.js required for various debug adapters and tools

### PHP Dependencies
- PHP CS Fixer must be available globally or in PATH
- PHPStan must be available in PATH
- XDebug requires Node.js for the debug adapter
- PHPUnit expected at `vendor/bin/phpunit` for project-specific testing
- Composer for dependency management

### JavaScript/TypeScript Dependencies
- Node.js and npm/yarn for package management
- ESLint for linting (configurable per project)
- Prettier for formatting (configurable per project)
- TypeScript LSP server installed via Mason
- Jest/Vitest for testing (project-specific)

### Terraform Dependencies
- Terraform CLI must be available in PATH
- TFLint recommended for enhanced linting
- Terraform LSP server installed via Mason
- GraphViz (dot) for dependency graph generation

### Kotlin Dependencies
- Kotlin Language Server installed via Mason
- ktlint must be available in PATH for formatting and linting
- Gradle or Maven for build management (project-specific)
- Java Debug Adapter installed via Mason
- JDK 17+ recommended for Kotlin development
- JUnit for testing (project-specific)

### Auto-Installation
Most LSP servers, formatters, and linters are automatically installed via Mason when first needed. The configuration assumes modern development environments with standard tooling for each language.