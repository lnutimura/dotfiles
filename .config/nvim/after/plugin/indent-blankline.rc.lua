local status, indent_blankline = pcall(require, "indent_blankline")
if (not status) then return end

vim.opt.list = true
vim.opt.listchars:append "tab:» "
vim.opt.listchars:append "trail:·"
vim.opt.listchars:append "space:·"

vim.cmd [[highlight IndentBlanklineChar guifg=#073642 gui=nocombine]]
vim.cmd [[highlight IndentBlanklineSpace guifg=#073642 gui=nocombine]]
vim.cmd [[highlight IndentBlanklineSpaceChar guifg=#073642 gui=nocombine]]
vim.cmd [[highlight IndentBlanklineSpaceCharBlankline guifg=#073642 gui=nocombine]]
vim.cmd [[match IndentBlanklineSpace /\s/]]
indent_blankline.setup({})
