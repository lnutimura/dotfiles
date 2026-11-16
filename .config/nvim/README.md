# nvim

Neovim 0.12+ config. Plugins are managed by the built-in
[`vim.pack`](https://neovim.io/doc/user/pack.html#vim.pack); the versions in
use are pinned in `nvim-pack-lock.json`.

## Layout

- `init.lua` loads the options, autocmds, keymaps and plugins, in that order.
- `lua/config/` has editor options, autocmds and keymaps.
- `lua/plugins/init.lua` has the build hooks and the load order of the plugin
  modules.
- `lua/plugins/<topic>.lua` adds its plugins with `vim.pack.add()`, then
  configures them and maps their keys.
- `after/lsp/<server>.lua` overrides nvim-lspconfig's defaults for one server.
  The servers to enable and the tools mason installs are listed in
  `lua/plugins/lsp.lua`.
- `lua/util/` has helpers shared by the modules.

## Plugins

- Add one: put its spec in a module's `vim.pack.add()` and restart.
- Update: `:lua vim.pack.update()`, review the changes, then `:write`.
- Remove one: delete its spec, restart, then
  `:lua vim.pack.del({ "name" })`.
- Restore the locked versions: `:lua vim.pack.update(nil, { target = "lockfile" })`.

## Requirements

`git`, `make` and a C compiler (parsers, telescope-fzf-native), `rg`, and a
Nerd Font. mason installs the language servers, formatters, linters and the
tree-sitter CLI.
