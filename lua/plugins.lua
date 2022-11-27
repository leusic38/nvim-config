-- Plugins repository
local M = {}

local packer_bootstrap = false

local function packer_init()
	
	local fn = vim.fn
	
	-- Automatically install packer
	local install_path = fn.stdpath "data" .. "/site/pack/packer/start/packer.nvim"
	if fn.empty(fn.glob(install_path)) > 0 then
	  PACKER_BOOTSTRAP = fn.system {
	    "git",
	    "clone",
	    "--depth",
	    "1",
	    "https://github.com/wbthomason/packer.nvim",
	    install_path,
	  }
	  print "Installing packer close and reopen Neovim..."
	  vim.cmd [[packadd packer.nvim]]
	end
	
	-- Autocommand that reloads neovim whenever you save the plugins.lua file
	vim.cmd [[
	  augroup packer_user_config
	    autocmd!
	    autocmd BufWritePost plugins.lua source <afile> | PackerSync
	  augroup end
	]]
	
	-- Use a protected call so we don't error out on first use
	local status_ok, packer = pcall(require, "packer")
	if not status_ok then
	  return
	end
	end
	-- Have packer use a popup window
	
	-- Load plugins lua path
--	  local lua_path = function(name)
--	    return string.format("require'config.%s'", name)
--	  end
	packer_init()

function M.setup()
  local conf = {
    compile_path = vim.fn.stdpath "config" .. "/lua/packer_compiled.lua",
    display = {
      open_fn = function()
        return require("packer.util").float { border = "rounded" }
      end,
    },
  }

  local function plugins(use)
	-- Install your plugins here
	  -- My plugins here
    use { 'lewis6991/impatient.nvim' } -- Speed up loading Lua modules in Neovim to improve startup time
	  use { "wbthomason/packer.nvim" } -- Have packer manage itself


    --- Versionning (git) ---

    use {
      "tpope/vim-fugitive", event = "BufRead"
    }
	  use {
      "lewis6991/gitsigns.nvim",
    }
	  use {
	     "TimUntersberger/neogit",
	   cmd = "Neogit",
	   requires = "nvim-lua/plenary.nvim",
	   config = function()
	       require("config.neogit").setup()
	   end,
	  }
    use {
      "rhysd/git-messenger.vim"
    }
    use {
      "sindrets/diffview.nvim",
      cmd = {
        "DiffviewOpen",
        "DiffviewClose",
        "DiffviewToggleFiles",
        "DiffviewFocusFiles",
      },
    }

    --- config ---
    -- WhichKey keymap
    use {
      "folke/which-key.nvim",
      config = function()
      require("config.whichkey").setup()
    end,
    }

    --- Development ---



	  use {"windwp/nvim-autopairs",
      run = "make",
      config = function()
        require("config.autopairs").setup()
      end,
    }
	  use "numToStr/Comment.nvim"-- Easily comment stuff
    use "norcalli/nvim-colorizer.lua" --colorized color expression
	  use "kyazdani42/nvim-web-devicons"
	  use {
      "kyazdani42/nvim-tree.lua",
      config = function()
         require("config.nvimtree").setup()
       end,
    }
	  use "goolord/alpha-nvim"
	  use {
      "sainnhe/everforest",
      config =function()
         require("config.everforest").setup()
       end,
    }
    use {"sonph/onehalf",
      rtp = "vim",
      config = function()
        require("config.onehalf").setup()
      end,
    }
    use {
        "ellisonleao/gruvbox.nvim",
        config = function()
          require("config.gruvbox").setup()
        end,
    }
	  use {
	      "iamcco/markdown-preview.nvim",
	      run = function()
	        vim.fn["mkdp#util#install"]()
	      end,
	      ft = "markdown",
	      cmd = { "MarkdownPreview" },
	    }
	  -- cmp plugins
	  use "hrsh7th/nvim-cmp" -- The completion plugin
	  use "hrsh7th/cmp-buffer" -- buffer completions
	  use "hrsh7th/cmp-path" -- path completions
	  use "hrsh7th/cmp-cmdline" -- cmdline completions
	  use "saadparwaiz1/cmp_luasnip" -- snippet completions
	  use "hrsh7th/cmp-nvim-lsp"
    use {'tzachar/cmp-tabnine', run='./install.sh'}
	
	  -- snippets
	  use "L3MON4D3/LuaSnip" --snippet engine
	  use "rafamadriz/friendly-snippets" -- a bunch of snippets to use
	
	  -- LSP
	  use {
      "neovim/nvim-lspconfig",
       opt = true,
      event = "BufReadPre",
      wants = { "nvim-lsp-installer" },
      config = function()
        require("config.lsp").setup()
      end,
      requires = {
       "williamboman/nvim-lsp-installer",
      },
    }-- enable LSP
--	  use "williamboman/nvim-lsp-installer" -- simple to use language server installer
--	  use "tamago324/nlsp-settings.nvim" -- language server settings defined in json for
--	  use "jose-elias-alvarez/null-ls.nvim" -- for formatters and linters
	
	  -- Telescope
    use {
      "stevearc/gkeep.nvim",
      run = ":UpdateRemotePlugins",
    }
    use {
      "AckslD/nvim-neoclip.lua",
      config = function()
        require("neoclip").setup()
      end,
    }
	  use "nvim-lua/popup.nvim" -- An implementation of the Popup API from vim in Neovim
	  use "nvim-lua/plenary.nvim" -- Useful lua functions used ny lots of plugins
	  use {
	    "nvim-telescope/telescope.nvim",
	     requires = {
        "nvim-telescope/telescope-project.nvim",
        "nvim-telescope/telescope-symbols.nvim",
        "nvim-telescope/telescope-media-files.nvim",
        "nvim-telescope/telescope-github.nvim",
        "fhill2/telescope-ultisnips.nvim",
        "cljoly/telescope-repo.nvim",
        "jvgrootveld/telescope-zoxide",
        {
          "dhruvmanila/telescope-bookmarks.nvim",
          requires = { "tami5/sqlite.lua" },
        },
        -- 'nvim-telescope/telescope-hop.nvim'
        {
          "nvim-telescope/telescope-fzf-native.nvim",
          run = "make"
        },
        {
          "nvim-telescope/telescope-arecibo.nvim",
          rocks = { "openssl", "lua-http-parser" },
        },
        {
          "nvim-telescope/telescope-frecency.nvim",
          requires = { "tami5/sql.nvim" },
        },
        {
          "nvim-telescope/telescope-vimspector.nvim",
          event = "BufWinEnter",
        },
        { "nvim-telescope/telescope-dap.nvim" },
      },
      config = function()
         require("config.telescope").setup()
       end
	  }
	  -- reesitter
	  use {
	    "nvim-treesitter/nvim-treesitter",
	    run = ":TSUpdate",
	  }
	  use "JoosepAlviste/nvim-ts-context-commentstring"
	  use {
	    "ThePrimeagen/refactoring.nvim",
	    event = "VimEnter",
	    config = function()
        require("config.refactoring").setup()
      end
	  }

	  if PACKER_BOOTSTRAP then
	    require("packer").sync()
	  end
	end
  pcall(require, "impatient")
  pcall(require, "packer_compiled")
  require("packer").init(conf)
  require("packer").startup(plugins)
end

return M
