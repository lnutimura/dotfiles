---@type vim.lsp.Config
return {
  settings = {
    pyright = {
      -- Ruff organizes imports.
      disableOrganizeImports = true,
    },
    python = {
      analysis = {
        -- Ruff does the linting; pyright only provides language features.
        ignore = { "*" },
      },
    },
  },
}
