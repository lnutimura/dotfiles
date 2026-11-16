vim.loader.enable()

_G.dd = function(...)
  require("util.debug").dump(...)
end
vim.print = _G.dd

require("config.options")
require("config.autocmds")
require("config.keymaps")
require("plugins")
