return {
  {
    "mistpine/mistpine.nvim",
    lazy = false,
    priority = 1000,
    opts = {},
    config = function(_, opts)
      require("mistpine").setup(opts)
      vim.cmd.colorscheme("mistpine")
    end,
  },
}
