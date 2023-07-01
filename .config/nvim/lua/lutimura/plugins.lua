local status, packer = pcall(require, "packer")
if (not status) then
  print("Packer is not installed.")
  return
end

vim.cmd [[packadd packer.nvim]]

packer.startup(function(use)
  -- Packer
  use 'wbthomason/packer.nvim'

  -- Autopairs
  use 'windwp/nvim-autopairs'

  -- Autotag
  use 'windwp/nvim-ts-autotag'

  -- Bufferline
  use 'akinsho/bufferline.nvim'

  -- Built-in LSP enhancement
  use 'glepnir/lspsaga.nvim'

  -- Colorizer
  use 'norcalli/nvim-colorizer.lua'

  -- Comment
  use {
    'numToStr/Comment.nvim',
    requires = { 'JoosepAlviste/nvim-ts-context-commentstring' }
  }

  -- Common utilities
  use 'nvim-lua/plenary.nvim'

  -- Completion engine
  use 'hrsh7th/nvim-cmp'

  -- Devicons
  use 'kyazdani42/nvim-web-devicons'

  -- Easily install and manage: 
  -- * LSP servers;
  -- * DAP servers;
  -- * Linters; and
  -- * Formatters.
  use {
    "williamboman/mason.nvim",
    run = ":MasonUpdate"
  }

  -- File browser extension for `telescope.nvim`
  use 'nvim-telescope/telescope-file-browser.nvim'

  -- Fuzzy finder
  use 'nvim-telescope/telescope.nvim'

  -- Git decorations
  use 'lewis6991/gitsigns.nvim'

  -- Git wrapper
  use 'dinhhuy258/git.nvim'

  -- Indent guides
  use 'lukas-reineke/indent-blankline.nvim'

  -- Neovim as a language server to:
  -- * Inject LSP diagnostics;
  -- * Code actions;
  -- * etc.
  use 'jose-elias-alvarez/null-ls.nvim'

  -- `nvim-cmp` source for built-in LSP
  use 'hrsh7th/cmp-nvim-lsp'

  -- `nvim-cmp` source for buffer words
  use 'hrsh7th/cmp-buffer'

  -- `nvim-cmp` source for path
  use 'hrsh7th/cmp-path'

  -- Quickstart configs for built-in LSP
  use 'neovim/nvim-lspconfig'

  -- Snippet engine
  use 'L3MON4D3/LuaSnip'

  -- Statusline
  use 'nvim-lualine/lualine.nvim'

  -- Theme
  use {
    'svrana/neosolarized.nvim',
    requires = { 'tjdevries/colorbuddy.nvim' }
  }

  -- Treesitter configurations and abstraction layer
  use {
    'nvim-treesitter/nvim-treesitter',
    run = function() require('nvim-treesitter.install').update({ with_sync = true }) end,
  }

  -- VSCode-like pictograms
  use 'onsails/lspkind.nvim'

  -- Extension that makes it easier to use `lspconfig` with `mason.nvim`.
  use 'williamboman/mason-lspconfig.nvim'
end)
