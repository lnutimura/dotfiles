return {
  -- treesitter
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "cmake",
        "cpp",
        "css",
        "gitignore",
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
