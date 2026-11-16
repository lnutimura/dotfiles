local gh = require("util").gh

vim.pack.add({
  { src = gh("nvim-treesitter/nvim-treesitter"), version = "main" },
  { src = gh("nvim-treesitter/nvim-treesitter-textobjects"), version = "main" },
})

local parsers = {
  "bash",
  "c",
  "cmake",
  "cpp",
  "css",
  "diff",
  "dockerfile",
  "gitignore",
  "go",
  "gomod",
  "gosum",
  "gotmpl",
  "gowork",
  "hcl",
  "html",
  "http",
  "java",
  "javascript",
  "jsdoc",
  "json",
  "json5",
  "kotlin",
  "lua",
  "luadoc",
  "luap",
  "markdown",
  "markdown_inline",
  "ninja",
  "printf",
  "python",
  "query",
  "regex",
  "rst",
  "sql",
  "terraform",
  "toml",
  "tsx",
  "typescript",
  "vim",
  "vimdoc",
  "xml",
  "yaml",
}

-- Installing compiles parsers with the tree-sitter CLI, which mason provides
-- (plugins/lsp.lua). On a fresh machine, wait until mason has installed it.
local function install_parsers()
  require("nvim-treesitter").install(parsers)
end
if vim.fn.executable("tree-sitter") == 1 then
  install_parsers()
else
  vim.api.nvim_create_autocmd("User", {
    pattern = "MasonToolsUpdateCompleted",
    once = true,
    callback = install_parsers,
  })
end

require("nvim-treesitter-textobjects").setup({ move = { set_jumps = true } })

-- Text object motions: { key, nvim-treesitter-textobjects.move function, capture }.
local moves = {
  { "]f", "goto_next_start", "@function.outer" },
  { "]c", "goto_next_start", "@class.outer" },
  { "]a", "goto_next_start", "@parameter.inner" },
  { "]F", "goto_next_end", "@function.outer" },
  { "]C", "goto_next_end", "@class.outer" },
  { "]A", "goto_next_end", "@parameter.inner" },
  { "[f", "goto_previous_start", "@function.outer" },
  { "[c", "goto_previous_start", "@class.outer" },
  { "[a", "goto_previous_start", "@parameter.inner" },
  { "[F", "goto_previous_end", "@function.outer" },
  { "[C", "goto_previous_end", "@class.outer" },
  { "[A", "goto_previous_end", "@parameter.inner" },
}

---@param buf integer
local function map_moves(buf)
  for _, move in ipairs(moves) do
    local key, method, capture = move[1], move[2], move[3]
    vim.keymap.set({ "n", "x", "o" }, key, function()
      -- ]c and [c keep jumping between changes in diff mode.
      if vim.wo.diff and key:find("[cC]") then
        return vim.cmd.normal({ key, bang = true })
      end
      require("nvim-treesitter-textobjects.move")[method](capture, "textobjects")
    end, { buffer = buf, silent = true, desc = method:gsub("_", " ") .. " " .. capture })
  end
end

-- Per buffer: highlighting, indentation and text object motions, each only
-- when the language has a parser and the matching query.
vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("user_treesitter", { clear = true }),
  callback = function(ev)
    local lang = vim.treesitter.language.get_lang(ev.match)
    if not lang or not pcall(vim.treesitter.start, ev.buf, lang) then
      return
    end
    if vim.treesitter.query.get(lang, "indents") then
      vim.bo[ev.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
    end
    if vim.treesitter.query.get(lang, "textobjects") then
      map_moves(ev.buf)
    end
  end,
})
