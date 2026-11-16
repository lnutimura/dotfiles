local gh = require("util").gh
local icons = require("util.icons")

vim.pack.add({
  gh("nvim-mini/mini.nvim"),
  gh("monaqa/dial.nvim"),
  gh("folke/lazydev.nvim"),
  gh("rafamadriz/friendly-snippets"),
  -- Release tags ship a prebuilt fuzzy matcher (no Rust toolchain needed).
  { src = gh("saghen/blink.cmp"), version = vim.version.range("1.*") },
})

-- Text objects: a/i extended with treesitter and pattern objects.
local ai = require("mini.ai")
ai.setup({
  n_lines = 500,
  custom_textobjects = {
    o = ai.gen_spec.treesitter({ -- code block
      a = { "@block.outer", "@conditional.outer", "@loop.outer" },
      i = { "@block.inner", "@conditional.inner", "@loop.inner" },
    }),
    f = ai.gen_spec.treesitter({ a = "@function.outer", i = "@function.inner" }), -- function
    c = ai.gen_spec.treesitter({ a = "@class.outer", i = "@class.inner" }), -- class
    t = { "<([%p%w]-)%f[^<%w][^<>]->.-</%1>", "^<.->().*()</[^/]->$" }, -- tags
    d = { "%f[%d]%d+" }, -- digits
    e = { -- word with case
      { "%u[%l%d]+%f[^%l%d]", "%f[%S][%l%d]+%f[^%l%d]", "%f[%P][%l%d]+%f[^%l%d]", "^[%l%d]+%f[^%l%d]" },
      "^().*()$",
    },
    g = require("mini.extra").gen_ai_spec.buffer(), -- whole buffer
    u = ai.gen_spec.function_call(), -- u for "usage"
    U = ai.gen_spec.function_call({ name_pattern = "[%w_]" }), -- without dot in the name
  },
})

require("mini.pairs").setup({
  modes = { insert = true, command = true, terminal = false },
})

require("mini.align").setup()

-- Go forward/backward with square brackets. An empty suffix disables a target.
require("mini.bracketed").setup({
  file = { suffix = "" },
  window = { suffix = "" },
  quickfix = { suffix = "" },
  yank = { suffix = "" },
  treesitter = { suffix = "n" },
})

-- Increment/decrement.
local augend = require("dial.augend")
require("dial.config").augends:register_group({
  default = {
    augend.integer.alias.decimal,
    augend.integer.alias.hex,
    augend.date.alias["%Y/%m/%d"],
    augend.constant.alias.bool,
    augend.semver.alias.semver,
    augend.constant.new({ elements = { "let", "const" } }),
  },
})
vim.keymap.set("n", "+", function()
  return require("dial.map").inc_normal()
end, { expr = true, desc = "Increment" })
vim.keymap.set("n", "-", function()
  return require("dial.map").dec_normal()
end, { expr = true, desc = "Decrement" })

-- lua_ls support for the Neovim API and plugins while editing this config.
require("lazydev").setup({
  library = {
    { path = "${3rd}/luv/library", words = { "vim%.uv" } },
    { path = "snacks.nvim", words = { "Snacks" } },
    { path = "nvim-lspconfig", words = { "lspconfig.settings" } },
  },
})

-- Completion.
require("blink.cmp").setup({
  appearance = {
    nerd_font_variant = "mono",
    kind_icons = icons.kinds,
  },
  completion = {
    accept = { auto_brackets = { enabled = true } },
    menu = {
      winblend = vim.o.pumblend,
      draw = { treesitter = { "lsp" } },
    },
    documentation = { auto_show = true, auto_show_delay_ms = 200 },
    ghost_text = { enabled = true },
  },
  sources = {
    default = { "lsp", "path", "snippets", "buffer" },
    per_filetype = {
      lua = { inherit_defaults = true, "lazydev" },
    },
    providers = {
      lazydev = {
        name = "LazyDev",
        module = "lazydev.integrations.blink",
        score_offset = 100, -- above LSP items
      },
    },
  },
  cmdline = {
    keymap = {
      preset = "cmdline",
      ["<Right>"] = false,
      ["<Left>"] = false,
    },
    completion = {
      list = { selection = { preselect = false } },
      menu = {
        auto_show = function()
          return vim.fn.getcmdtype() == ":"
        end,
      },
      ghost_text = { enabled = true },
    },
  },
  keymap = {
    preset = "enter",
    ["<C-y>"] = { "select_and_accept" },
  },
})
