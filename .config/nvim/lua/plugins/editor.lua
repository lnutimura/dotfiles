local gh = require("util").gh
local map = vim.keymap.set

vim.pack.add({
  gh("nvim-lua/plenary.nvim"),
  gh("nvim-telescope/telescope.nvim"),
  gh("nvim-telescope/telescope-fzf-native.nvim"),
  gh("nvim-telescope/telescope-file-browser.nvim"),
  gh("dinhhuy258/git.nvim"),
  gh("kazhala/close-buffers.nvim"),
  gh("lewis6991/gitsigns.nvim"),
  gh("folke/todo-comments.nvim"),
  gh("brenoprata10/nvim-highlight-colors"),
})

-- Fuzzy finder.
local telescope = require("telescope")
local actions = require("telescope.actions")
local builtin = require("telescope.builtin")
local fb_actions = telescope.extensions.file_browser.actions

--- Move the selection by `count` entries (negative moves up).
---@param count integer
local function move_selection(count)
  local move = count > 0 and actions.move_selection_next or actions.move_selection_previous
  return function(prompt_bufnr)
    for _ = 1, math.abs(count) do
      move(prompt_bufnr)
    end
  end
end

telescope.setup({
  defaults = {
    prompt_prefix = "\u{F054} ",
    selection_caret = "\u{F44A} ",
    -- Open files in the first window that shows a regular buffer.
    get_selection_window = function()
      local wins = vim.api.nvim_list_wins()
      table.insert(wins, 1, vim.api.nvim_get_current_win())
      for _, win in ipairs(wins) do
        if vim.bo[vim.api.nvim_win_get_buf(win)].buftype == "" then
          return win
        end
      end
      return 0
    end,
    wrap_results = true,
    layout_strategy = "horizontal",
    layout_config = { prompt_position = "top" },
    sorting_strategy = "ascending",
    winblend = 0,
    mappings = {
      i = {
        ["<C-Down>"] = actions.cycle_history_next,
        ["<C-Up>"] = actions.cycle_history_prev,
        ["<C-f>"] = actions.preview_scrolling_down,
        ["<C-b>"] = actions.preview_scrolling_up,
      },
      n = { ["q"] = actions.close },
    },
  },
  pickers = {
    find_files = {
      find_command = { "rg", "--files", "--color", "never", "-g", "!.git" },
      hidden = true,
    },
    diagnostics = {
      theme = "ivy",
      initial_mode = "normal",
      layout_config = { preview_cutoff = 9999 },
    },
  },
  extensions = {
    file_browser = {
      theme = "dropdown",
      -- Replace netrw with the file browser.
      hijack_netrw = true,
      mappings = {
        n = {
          ["N"] = fb_actions.create,
          ["h"] = fb_actions.goto_parent_dir,
          ["/"] = function()
            vim.cmd.startinsert()
          end,
          ["<C-u>"] = move_selection(-10),
          ["<C-d>"] = move_selection(10),
          ["<PageUp>"] = actions.preview_scrolling_up,
          ["<PageDown>"] = actions.preview_scrolling_down,
        },
      },
    },
  },
})
telescope.load_extension("fzf")
telescope.load_extension("file_browser")

map("n", ";f", function()
  builtin.find_files({ no_ignore = false, hidden = true })
end, { desc = "Find files (respects .gitignore)" })
map("n", ";r", function()
  builtin.live_grep({ additional_args = { "--hidden" } })
end, { desc = "Live grep (respects .gitignore)" })
map("n", "\\\\", builtin.buffers, { desc = "Buffers" })
map("n", ";t", builtin.help_tags, { desc = "Help tags" })
map("n", ";;", builtin.resume, { desc = "Resume the last picker" })
map("n", ";e", builtin.diagnostics, { desc = "Diagnostics" })
map("n", ";s", builtin.treesitter, { desc = "Treesitter symbols" })
map("n", ";c", builtin.lsp_incoming_calls, { desc = "LSP incoming calls" })
map("n", "<Leader>fP", function()
  builtin.find_files({ cwd = vim.fn.stdpath("data") .. "/site/pack/core/opt" })
end, { desc = "Find Plugin File" })
map("n", "sf", function()
  telescope.extensions.file_browser.file_browser({
    path = "%:p:h",
    cwd = vim.fn.expand("%:p:h"),
    respect_gitignore = false,
    hidden = true,
    grouped = true,
    previewer = false,
    initial_mode = "normal",
    layout_config = { height = 40 },
  })
end, { desc = "File browser at the current buffer" })

-- Git.
require("git").setup({
  keymaps = {
    blame = "<Leader>gb",
    browse = "<Leader>go",
  },
})

require("gitsigns").setup({
  signs = {
    add = { text = "▎" },
    change = { text = "▎" },
    delete = { text = "\u{F0DA}" },
    topdelete = { text = "\u{F0DA}" },
    changedelete = { text = "▎" },
    untracked = { text = "▎" },
  },
  signs_staged = {
    add = { text = "▎" },
    change = { text = "▎" },
    delete = { text = "\u{F0DA}" },
    topdelete = { text = "\u{F0DA}" },
    changedelete = { text = "▎" },
  },
  on_attach = function(buf)
    local gs = require("gitsigns")
    local function bmap(mode, lhs, rhs, desc)
      map(mode, lhs, rhs, { buffer = buf, desc = desc, silent = true })
    end
    -- In diff mode, ]h and [h fall back to ]c and [c.
    for lhs, dir in pairs({ ["]h"] = "next", ["[h"] = "prev" }) do
      bmap("n", lhs, function()
        if vim.wo.diff then
          vim.cmd.normal({ dir == "next" and "]c" or "[c", bang = true })
        else
          gs.nav_hunk(dir)
        end
      end, dir == "next" and "Next Hunk" or "Prev Hunk")
    end
    bmap({ "n", "x" }, "<Leader>ghs", ":Gitsigns stage_hunk<CR>", "Stage Hunk")
    bmap({ "n", "x" }, "<Leader>ghr", ":Gitsigns reset_hunk<CR>", "Reset Hunk")
    bmap("n", "<Leader>ghp", gs.preview_hunk_inline, "Preview Hunk Inline")
    bmap("n", "<Leader>ghb", function()
      gs.blame_line({ full = true })
    end, "Blame Line")
    bmap({ "o", "x" }, "ih", ":<C-u>Gitsigns select_hunk<CR>", "Select Hunk")
  end,
})

-- Buffers.
map("n", "<Leader>th", function()
  require("close_buffers").delete({ type = "hidden" })
end, { desc = "Close Hidden Buffers" })
map("n", "<Leader>tu", function()
  require("close_buffers").delete({ type = "nameless" })
end, { desc = "Close Nameless Buffers" })

-- TODO/FIX/NOTE comments.
local todo = require("todo-comments")
todo.setup({})
map("n", "]t", todo.jump_next, { desc = "Next Todo Comment" })
map("n", "[t", todo.jump_prev, { desc = "Previous Todo Comment" })

-- Color codes rendered in their color.
require("nvim-highlight-colors").setup({
  render = "background",
  enable_hex = true,
  enable_short_hex = true,
  enable_rgb = true,
  enable_hsl = true,
  enable_hsl_without_function = true,
  enable_ansi = true,
  enable_var_usage = true,
  enable_tailwind = true,
})
