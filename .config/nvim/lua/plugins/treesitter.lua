return {
  -- treesitter
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "bash",
        "cmake",
        "cpp",
        "css",
        "dockerfile",
        "gitignore",
        "go",
        "gotmpl",
        "hcl",
        "http",
        "java",
        "kotlin",
        "lua",
        "python",
        "regex",
        "sql",
        "terraform",
      },
    },
  },
}
