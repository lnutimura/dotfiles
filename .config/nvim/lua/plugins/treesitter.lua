return {
  -- treesitter
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
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
        "sql",
        "terraform",
      },
    },
  },
}
