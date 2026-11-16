---@type vim.lsp.Config
return {
  -- Load the SchemaStore catalog only when the server starts.
  before_init = function(_, config)
    local json = config.settings.json --[[@as table]]
    json.schemas = vim.list_extend(json.schemas or {}, require("schemastore").json.schemas())
  end,
  settings = {
    json = {
      format = { enable = true },
      validate = { enable = true },
    },
  },
}
