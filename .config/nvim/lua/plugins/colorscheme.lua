local gh = require("util").gh

vim.pack.add({ gh("mistpine/mistpine.nvim") })

require("mistpine").setup({})
vim.cmd.colorscheme("mistpine")
