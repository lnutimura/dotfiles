-- Formatting (conform) and linting (nvim-lint). Install new tools by adding
-- them to `tools` in plugins/lsp.lua.
local gh = require("util").gh

vim.pack.add({
  gh("stevearc/conform.nvim"),
  gh("mfussenegger/nvim-lint"),
})

--- Format on save unless disabled for the buffer (vim.b.autoformat) or
--- globally (vim.g.autoformat); the buffer setting wins.
---@param buf integer
local function autoformat(buf)
  local enabled = vim.b[buf].autoformat
  if enabled == nil then
    enabled = vim.g.autoformat ~= false
  end
  return enabled
end

local conform = require("conform")
conform.setup({
  default_format_opts = {
    timeout_ms = 3000,
    lsp_format = "fallback", -- no formatter configured: let the LSP format
  },
  formatters_by_ft = {
    fish = { "fish_indent" },
    go = { "goimports", "gofumpt" },
    lua = { "stylua" },
    markdown = { "markdownlint-cli2", "markdown-toc" },
    sh = { "shfmt" },
  },
  formatters = {
    injected = { options = { ignore_errors = true } },
    -- Only when the file has a <!-- toc --> marker.
    ["markdown-toc"] = {
      condition = function(_, ctx)
        for _, line in ipairs(vim.api.nvim_buf_get_lines(ctx.buf, 0, -1, false)) do
          if line:find("<!%-%- toc %-%->") then
            return true
          end
        end
        return false
      end,
    },
    -- Only when markdownlint has something to fix.
    ["markdownlint-cli2"] = {
      condition = function(_, ctx)
        local diagnostics = vim.tbl_filter(function(d)
          return d.source == "markdownlint"
        end, vim.diagnostic.get(ctx.buf))
        return #diagnostics > 0
      end,
    },
  },
  format_on_save = function(buf)
    return autoformat(buf) and {} or nil
  end,
})
vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"

vim.keymap.set({ "n", "x" }, "<Leader>cf", function()
  conform.format()
end, { desc = "Format" })

-- <Leader>uf toggles autoformat globally, <Leader>uF for the buffer.
for lhs, buffer in pairs({ ["<Leader>uf"] = false, ["<Leader>uF"] = true }) do
  Snacks.toggle({
    name = "Auto Format (" .. (buffer and "Buffer" or "Global") .. ")",
    get = function()
      if buffer then
        return autoformat(0)
      end
      return vim.g.autoformat ~= false
    end,
    set = function(state)
      if buffer then
        vim.b.autoformat = state
      else
        vim.g.autoformat = state
        vim.b.autoformat = nil
      end
    end,
  }):map(lhs)
end

-- Linting, debounced: runs 100ms after the last trigger.
local lint = require("lint")
lint.linters_by_ft = {
  dockerfile = { "hadolint" },
  fish = { "fish" },
  go = { "golangcilint" },
  markdown = { "markdownlint-cli2" },
}
local lint_timer = assert(vim.uv.new_timer())
vim.api.nvim_create_autocmd({ "BufReadPost", "BufWritePost", "InsertLeave" }, {
  group = vim.api.nvim_create_augroup("user_lint", { clear = true }),
  callback = function()
    lint_timer:start(100, 0, vim.schedule_wrap(lint.try_lint))
  end,
})
