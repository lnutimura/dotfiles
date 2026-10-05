-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

vim.opt.backupskip = { "/tmp/*", "/private/tmp/*" }
vim.opt.breakindent = true
vim.opt.inccommand = "split"
vim.opt.mouse = ""
vim.opt.path:append({ "**" })
vim.opt.scrolloff = 10
vim.opt.splitkeep = "cursor"
vim.opt.title = true
vim.opt.wildignore:append({ "*/node_modules/*" })

vim.g.lazyvim_cmp = "blink.cmp"
vim.g.lazyvim_picker = "telescope"
vim.g.lazyvim_prettier_needs_config = true
