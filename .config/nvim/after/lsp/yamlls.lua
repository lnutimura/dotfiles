---@type vim.lsp.Config
return {
  -- Tell yamlls the client folds whole lines only.
  capabilities = {
    textDocument = {
      foldingRange = {
        dynamicRegistration = false,
        lineFoldingOnly = true,
      },
    },
  },
  -- Load the SchemaStore catalog only when the server starts.
  before_init = function(_, config)
    local yaml = config.settings.yaml --[[@as table]]
    yaml.schemas = vim.tbl_deep_extend("force", yaml.schemas or {}, require("schemastore").yaml.schemas())
  end,
  settings = {
    yaml = {
      keyOrdering = false,
      validate = true,
      -- The built-in store is replaced by SchemaStore.nvim; an empty url
      -- avoids "Cannot read properties of undefined (reading 'length')".
      schemaStore = { enable = false, url = "" },
    },
  },
}
