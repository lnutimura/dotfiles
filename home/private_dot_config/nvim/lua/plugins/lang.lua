-- Language-specific tools.
local gh = require("util").gh

vim.pack.add({
  gh("iamcco/markdown-preview.nvim"), -- built by the hook in plugins/init.lua
  gh("linux-cultist/venv-selector.nvim"),
})

-- venv-selector types every option as required; unset ones use the defaults.
---@diagnostic disable: missing-fields
require("venv-selector").setup({
  options = {
    notify_user_on_venv_activation = true,
    override_notify = false,
  },
})
---@diagnostic enable: missing-fields

-- Buffer-local keymaps per filetype.
local keys = {
  markdown = { "<Leader>cp", "<Cmd>MarkdownPreviewToggle<CR>", "Markdown Preview" },
  python = { "<Leader>cv", "<Cmd>VenvSelect<CR>", "Select VirtualEnv" },
}
vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("user_lang_keys", { clear = true }),
  pattern = vim.tbl_keys(keys),
  callback = function(ev)
    local key = keys[ev.match]
    vim.keymap.set("n", key[1], key[2], { buffer = ev.buf, desc = key[3] })
  end,
})
