-- Leaders must be set before any mapping is defined.
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- Keep markdown indentation at 'shiftwidth'.
vim.g.markdown_recommended_style = 0

local opt = vim.opt

-- Editing
opt.autowrite = true
opt.backupskip = { "/tmp/*", "/private/tmp/*" }
opt.confirm = true
opt.expandtab = true
opt.mouse = ""
opt.shiftround = true
opt.shiftwidth = 2
opt.smartindent = true
opt.tabstop = 2
opt.timeoutlen = 300
opt.undofile = true
opt.undolevels = 10000
opt.updatetime = 200
opt.virtualedit = "block"

-- Search and command line
opt.ignorecase = true
opt.inccommand = "split"
opt.path:append({ "**" })
opt.smartcase = true
opt.wildignore:append({ "*/node_modules/*" })
opt.wildmode = "longest:full,full"

-- Display
opt.breakindent = true
opt.cursorline = true
opt.fillchars = {
  foldopen = "",
  foldclose = "",
  fold = " ",
  foldsep = " ",
  diff = "╱",
  eob = " ",
}
opt.laststatus = 3
opt.linebreak = true
opt.list = true
opt.number = true
opt.pumblend = 10
opt.pumheight = 10
opt.relativenumber = true
opt.scrolloff = 10
opt.shortmess:append({ W = true, I = true, c = true, C = true })
opt.showmode = false
opt.sidescrolloff = 8
opt.signcolumn = "yes"
opt.smoothscroll = true
opt.title = true
opt.wrap = false

-- Windows
opt.splitbelow = true
opt.splitkeep = "cursor"
opt.splitright = true
opt.winminwidth = 5

-- Folding: treesitter folds, all open. foldexpr returns "0" without a parser.
opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
opt.foldlevel = 99
opt.foldmethod = "expr"
opt.foldtext = ""

-- Use the system clipboard, except over SSH where OSC 52 takes over.
-- Deferred because probing the clipboard provider is slow.
vim.schedule(function()
  vim.o.clipboard = vim.env.SSH_CONNECTION and "" or "unnamedplus"
end)
