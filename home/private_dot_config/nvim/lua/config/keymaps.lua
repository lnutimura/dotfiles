-- Editor keymaps. Plugin keymaps live next to their plugin in lua/plugins/.
local map = vim.keymap.set

-- Delete and change without touching the registers; paste the last yank.
map("n", "x", '"_x')
map({ "n", "v" }, "c", '"_c')
map({ "n", "v" }, "C", '"_C')
map({ "n", "v" }, "<Leader>d", '"_d')
map({ "n", "v" }, "<Leader>D", '"_D')
map({ "n", "v" }, "<Leader>p", '"0p')
map("n", "<Leader>P", '"0P')

-- Delete a word backwards.
map("n", "dw", 'vb"_d')

-- Select all.
map("n", "<C-a>", "gg<S-v>G")

-- Open a line without continuing the comment.
map("n", "<Leader>o", "o<Esc>^Da", { silent = true })
map("n", "<Leader>O", "O<Esc>^Da", { silent = true })

-- Jump forward in the jumplist (<C-i> is <Tab>, which switches tabs).
map("n", "<C-m>", "<C-i>", { silent = true })

-- Tabs.
map("n", "te", ":tabedit")
map("n", "<Tab>", "<Cmd>tabnext<CR>")
map("n", "<S-Tab>", "<Cmd>tabprev<CR>")

-- Windows: split, move, resize.
map("n", "ss", "<Cmd>split<CR>")
map("n", "sv", "<Cmd>vsplit<CR>")
map("n", "sh", "<C-w>h")
map("n", "sj", "<C-w>j")
map("n", "sk", "<C-w>k")
map("n", "sl", "<C-w>l")
map("n", "<C-w><Left>", "<C-w><")
map("n", "<C-w><Right>", "<C-w>>")
map("n", "<C-w><Up>", "<C-w>+")
map("n", "<C-w><Down>", "<C-w>-")

-- Diagnostics.
map("n", "<C-j>", function()
  vim.diagnostic.jump({ count = 1, float = true })
end, { desc = "Next Diagnostic" })
map("n", "<Leader>cd", vim.diagnostic.open_float, { desc = "Line Diagnostics" })

-- Move by display line unless a count is given.
map({ "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true, desc = "Down" })
map({ "n", "x" }, "<Down>", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true, desc = "Down" })
map({ "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true, desc = "Up" })
map({ "n", "x" }, "<Up>", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true, desc = "Up" })

-- Clear the search highlight and stop the snippet session on escape.
map({ "i", "n", "s" }, "<Esc>", function()
  vim.cmd.nohlsearch()
  vim.snippet.stop()
  return "<Esc>"
end, { expr = true, desc = "Escape and Clear hlsearch" })

-- n always searches forward and N backward; open folds on the match.
map("n", "n", "'Nn'[v:searchforward].'zv'", { expr = true, desc = "Next Search Result" })
map({ "x", "o" }, "n", "'Nn'[v:searchforward]", { expr = true, desc = "Next Search Result" })
map("n", "N", "'nN'[v:searchforward].'zv'", { expr = true, desc = "Prev Search Result" })
map({ "x", "o" }, "N", "'nN'[v:searchforward]", { expr = true, desc = "Prev Search Result" })

-- Undo break-points while typing.
for _, char in ipairs({ ",", ".", ";" }) do
  map("i", char, char .. "<C-g>u")
end

map({ "i", "x", "n", "s" }, "<C-s>", "<Cmd>w<CR><Esc>", { desc = "Save File" })

-- Keep the selection after indenting.
map("x", "<", "<gv")
map("x", ">", ">gv")

map("n", "gco", "o<Esc>Vcx<Esc><Cmd>normal gcc<CR>fxa<BS>", { desc = "Add Comment Below" })
map("n", "gcO", "O<Esc>Vcx<Esc><Cmd>normal gcc<CR>fxa<BS>", { desc = "Add Comment Above" })
