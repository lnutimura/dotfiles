-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
--
-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

vim.opt.autoindent = true
vim.opt.backspace = { "start", "eol", "indent" }
vim.opt.backup = false
vim.opt.backupskip = { "/tmp/*", "/private/tmp/*" }
vim.opt.breakindent = true
vim.opt.cmdheight = 1
vim.opt.encoding = "utf-8"
vim.opt.expandtab = true
vim.opt.fileencoding = "utf-8"
vim.opt.formatoptions:append({ "r" })
vim.opt.hlsearch = true
vim.opt.ignorecase = true
vim.opt.inccommand = "split"
vim.opt.laststatus = 3
vim.opt.mouse = ""
vim.opt.number = true
vim.opt.path:append({ "**" })
vim.opt.scrolloff = 10
vim.opt.shiftwidth = 2
vim.opt.showcmd = true
vim.opt.smartindent = true
vim.opt.smarttab = true
vim.opt.splitbelow = true
vim.opt.splitkeep = "cursor"
vim.opt.splitright = true
vim.opt.tabstop = 2
vim.opt.title = true
vim.opt.wildignore:append({ "*/node_modules/*" })
vim.opt.wrap = false

vim.cmd([[let &t_Cs = "\e[4:3m"]])
vim.cmd([[let &t_Ce = "\e[4:0m"]])

vim.g.lazyvim_cmp = "blink.cmp"
vim.g.lazyvim_picker = "telescope"
vim.g.lazyvim_prettier_needs_config = true
vim.g.mapleader = " "
