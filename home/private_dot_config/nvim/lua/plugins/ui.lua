local gh = require("util").gh
local icons = require("util.icons")

vim.pack.add({
  gh("nvim-mini/mini.nvim"),
  gh("folke/snacks.nvim"),
  gh("MunifTanjim/nui.nvim"),
  gh("folke/noice.nvim"),
  gh("nvim-lualine/lualine.nvim"),
  gh("akinsho/bufferline.nvim"),
  gh("b0o/incline.nvim"),
  gh("folke/zen-mode.nvim"),
})

-- Icons. Plugins asking for nvim-web-devicons get mini.icons instead.
require("mini.icons").setup({
  file = {
    [".go-version"] = { glyph = "", hl = "MiniIconsBlue" },
    [".keep"] = { glyph = "󰊢", hl = "MiniIconsGrey" },
    ["devcontainer.json"] = { glyph = "", hl = "MiniIconsAzure" },
  },
  filetype = {
    dotenv = { glyph = "", hl = "MiniIconsYellow" },
    gotmpl = { glyph = "󰟓", hl = "MiniIconsGrey" },
  },
})
MiniIcons.mock_nvim_web_devicons()

-- snacks.nvim replaces vim.notify on setup. Restore it so noice (below)
-- takes over and keeps the notifications sent before it in its history;
-- noice then shows them through the snacks notifier.
local notify = vim.notify
require("snacks").setup({
  bigfile = { enabled = true },
  quickfile = { enabled = true },
  indent = { enabled = true },
  scope = { enabled = true },
  input = { enabled = true },
  notifier = { enabled = true, timeout = 5000 },
  picker = { enabled = true }, -- only for vim.ui.select; pickers are telescope
  statuscolumn = { enabled = true },
  words = { enabled = true },
})
vim.notify = notify

-- Messages, cmdline and popupmenu.
local focused = true
local focus = vim.api.nvim_create_augroup("user_noice_focus", { clear = true })
vim.api.nvim_create_autocmd("FocusGained", {
  group = focus,
  callback = function()
    focused = true
  end,
})
vim.api.nvim_create_autocmd("FocusLost", {
  group = focus,
  callback = function()
    focused = false
  end,
})

require("noice").setup({
  lsp = {
    override = {
      ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
      ["vim.lsp.util.stylize_markdown"] = true,
    },
  },
  routes = {
    -- Also send messages to the desktop while Neovim is unfocused.
    {
      filter = {
        cond = function()
          return not focused
        end,
      },
      view = "notify_send",
      opts = { stop = false },
    },
    -- Show write and undo messages in the mini view.
    {
      filter = {
        event = "msg_show",
        any = {
          { find = "%d+L, %d+B" },
          { find = "; after #%d+" },
          { find = "; before #%d+" },
        },
      },
      view = "mini",
    },
    {
      filter = { event = "notify", find = "No information available" },
      opts = { skip = true },
    },
  },
  commands = {
    -- The message history shown by `:Noice`.
    all = {
      view = "split",
      opts = { enter = true, format = "details" },
      filter = {},
    },
  },
  presets = {
    bottom_search = true,
    command_palette = true,
    inc_rename = true,
    long_message_to_split = true,
    lsp_doc_border = true,
  },
})

vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("user_noice_markdown", { clear = true }),
  pattern = "markdown",
  callback = function(event)
    vim.schedule(function()
      require("noice.text.markdown").keys(event.buf)
    end)
  end,
})

-- Scroll LSP hover and signature windows, or fall back to the default key.
for lhs, delta in pairs({ ["<C-f>"] = 4, ["<C-b>"] = -4 }) do
  vim.keymap.set({ "i", "n", "s" }, lhs, function()
    if not require("noice.lsp").scroll(delta) then
      return lhs
    end
  end, { silent = true, expr = true, desc = delta > 0 and "Scroll Forward" or "Scroll Backward" })
end

-- Statusline.
---@type table<string, { has: (fun(): boolean), get: (fun(): string?) }>
local noice_status = require("noice").api.status
local function fg(name)
  return function()
    return { fg = Snacks.util.color(name) }
  end
end

require("lualine").setup({
  options = { theme = "auto", globalstatus = true },
  sections = {
    lualine_a = { "mode" },
    lualine_b = { "branch" },
    lualine_c = {
      {
        "diagnostics",
        symbols = {
          error = icons.diagnostics.Error,
          warn = icons.diagnostics.Warn,
          info = icons.diagnostics.Info,
          hint = icons.diagnostics.Hint,
        },
      },
      { "filetype", icon_only = true, separator = "", padding = { left = 1, right = 0 } },
      { require("util.lualine").pretty_path() },
    },
    lualine_x = {
      { noice_status.command.get, cond = noice_status.command.has, color = fg("Statement") },
      -- The mode status carries "recording @q".
      { noice_status.mode.get, cond = noice_status.mode.has, color = fg("Constant") },
      {
        "diff",
        symbols = {
          added = icons.git.added,
          modified = icons.git.modified,
          removed = icons.git.removed,
        },
        source = function()
          local gitsigns = vim.b.gitsigns_status_dict
          if gitsigns then
            return {
              added = gitsigns.added,
              modified = gitsigns.changed,
              removed = gitsigns.removed,
            }
          end
        end,
      },
    },
    lualine_y = {
      { "progress", separator = " ", padding = { left = 1, right = 0 } },
      { "location", padding = { left = 0, right = 1 } },
    },
    lualine_z = {
      function()
        return "\u{F43A} " .. os.date("%R")
      end,
    },
  },
})

-- Tabline: tab pages, shown once there is more than one.
require("bufferline").setup({
  options = {
    mode = "tabs",
    always_show_bufferline = false,
    show_buffer_close_icons = false,
    show_close_icon = false,
    diagnostics = "nvim_lsp",
    diagnostics_indicator = function(_, _, diag)
      local ret = (diag.error and icons.diagnostics.Error .. diag.error .. " " or "")
        .. (diag.warning and icons.diagnostics.Warn .. diag.warning or "")
      return vim.trim(ret)
    end,
  },
})

-- File name in the top-right corner of each window.
require("incline").setup({
  window = { margin = { vertical = 0, horizontal = 1 } },
  hide = { cursorline = true },
  render = function(props)
    local filename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(props.buf), ":t")
    local icon, hl = MiniIcons.get("file", filename)
    if vim.bo[props.buf].modified then
      filename = "[+] " .. filename
    end
    return { { icon, group = hl }, { " " }, { filename } }
  end,
})

require("zen-mode").setup({
  plugins = {
    gitsigns = true,
    tmux = true,
    kitty = { enabled = false, font = "+2" },
  },
})
vim.keymap.set("n", "<Leader>z", "<Cmd>ZenMode<CR>", { desc = "Zen Mode" })
