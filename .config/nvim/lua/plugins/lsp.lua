-- Native LSP: nvim-lspconfig supplies the server defaults (lsp/*.lua) and
-- after/lsp/<server>.lua overrides them. mason installs servers and tools.
local gh = require("util").gh
local icons = require("util.icons")

vim.pack.add({
  gh("neovim/nvim-lspconfig"),
  gh("mason-org/mason.nvim"),
  gh("mason-org/mason-lspconfig.nvim"), -- lspconfig <-> mason names only
  gh("WhoIsSethDaniel/mason-tool-installer.nvim"),
  gh("b0o/SchemaStore.nvim"),
  gh("smjonas/inc-rename.nvim"),
})

-- Servers to enable, by lspconfig name.
local servers = {
  "dockerls",
  "gopls",
  "jsonls",
  "lua_ls",
  "marksman",
  "pyright",
  "ruff",
  "taplo",
  "tofu_ls",
  "yamlls",
}

-- Command-line tools, by mason name: formatters and linters used in
-- plugins/format.lua, and the tree-sitter CLI that builds parsers.
local tools = {
  "goimports",
  "gofumpt",
  "golangci-lint",
  "hadolint",
  "markdown-toc",
  "markdownlint-cli2",
  "shellcheck",
  "shfmt",
  "stylua",
  "tree-sitter-cli",
}

require("mason").setup()
require("mason-tool-installer").setup({
  ensure_installed = vim.list_extend(vim.deepcopy(servers), tools),
})
vim.lsp.enable(servers)

require("inc_rename").setup({})

vim.diagnostic.config({
  underline = true,
  update_in_insert = false,
  virtual_text = { spacing = 4, source = "if_many", prefix = "●" },
  severity_sort = true,
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = icons.diagnostics.Error,
      [vim.diagnostic.severity.WARN] = icons.diagnostics.Warn,
      [vim.diagnostic.severity.HINT] = icons.diagnostics.Hint,
      [vim.diagnostic.severity.INFO] = icons.diagnostics.Info,
    },
  },
})

--- A keymap that opens a telescope LSP picker.
---@param picker string
---@param opts? table
local function telescope(picker, opts)
  return function()
    require("telescope.builtin")[picker](opts)
  end
end

-- Buffer-local LSP keymaps. `method` (textDocument/*) skips a key when the
-- server lacks it. Neovim's defaults (K, grn, gra, grr, gri, ...) remain.
local keys = {
  { "gd", telescope("lsp_definitions", { reuse_win = true }), desc = "Goto Definition", method = "definition" },
  { "gr", telescope("lsp_references"), desc = "References", nowait = true, method = "references" },
  { "gI", telescope("lsp_implementations", { reuse_win = true }), desc = "Goto Implementation" },
  { "gy", telescope("lsp_type_definitions", { reuse_win = true }), desc = "Goto T[y]pe Definition" },
  { "gD", vim.lsp.buf.declaration, desc = "Goto Declaration" },
  { "gK", vim.lsp.buf.signature_help, desc = "Signature Help", method = "signatureHelp" },
  { "<C-k>", vim.lsp.buf.signature_help, mode = "i", desc = "Signature Help", method = "signatureHelp" },
  { "<Leader>ca", vim.lsp.buf.code_action, mode = { "n", "x" }, desc = "Code Action", method = "codeAction" },
  {
    "<Leader>cr",
    function()
      return ":" .. require("inc_rename").config.cmd_name .. " " .. vim.fn.expand("<cword>")
    end,
    expr = true,
    desc = "Rename (inc-rename.nvim)",
    method = "rename",
  },
  {
    "]]",
    function()
      Snacks.words.jump(vim.v.count1)
    end,
    desc = "Next Reference",
    method = "documentHighlight",
  },
  {
    "[[",
    function()
      Snacks.words.jump(-vim.v.count1)
    end,
    desc = "Prev Reference",
    method = "documentHighlight",
  },
}

vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("user_lsp_keymaps", { clear = true }),
  callback = function(ev)
    local client = assert(vim.lsp.get_client_by_id(ev.data.client_id))
    for _, key in ipairs(keys) do
      if not key.method or client:supports_method("textDocument/" .. key.method, ev.buf) then
        vim.keymap.set(key.mode or "n", key[1], key[2], {
          buffer = ev.buf,
          desc = key.desc,
          expr = key.expr,
          nowait = key.nowait,
        })
      end
    end
  end,
})
