local status_mason, mason = pcall(require, "mason")
if (not status_mason) then return end

local status_lspconfig, lspconfig = pcall(require, "mason-lspconfig")
if (not status_lspconfig) then return end

mason.setup({})

lspconfig.setup {
  automatic_installation = true
}
