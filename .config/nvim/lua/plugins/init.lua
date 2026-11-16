-- Plugins are managed by vim.pack (:h vim.pack). Each module below adds the
-- plugins it loads (a repeated add is a no-op), then configures them and
-- maps their keys. Removing a plugin means deleting its block.
--
-- Update: :lua vim.pack.update()  (review, then :write to apply)
-- Remove: delete its spec, restart, then :lua vim.pack.del({ "name" })

--- Run a build command and report failures.
---@param cmd string[]
---@param cwd string
local function run(cmd, cwd)
  local result = vim.system(cmd, { cwd = cwd }):wait()
  if result.code ~= 0 then
    vim.notify(
      ("`%s` failed in %s:\n%s"):format(table.concat(cmd, " "), cwd, result.stderr or ""),
      vim.log.levels.ERROR
    )
  end
end

-- Build steps, keyed by plugin name, run after install and update.
---@type table<string, fun(data: { kind: string, active: boolean, path: string })>
local builds = {
  ["nvim-treesitter"] = function(data)
    -- New installs get their parsers from plugins/treesitter.lua.
    if data.kind == "update" and data.active then
      require("nvim-treesitter").update()
    end
  end,
  ["telescope-fzf-native.nvim"] = function(data)
    run({ "make" }, data.path)
  end,
  ["markdown-preview.nvim"] = function(data)
    local manifest = vim.json.decode(table.concat(vim.fn.readfile(data.path .. "/package.json"), "\n"))
    run({ "./install.sh", "v" .. manifest.version }, data.path .. "/app")
  end,
}

-- Registered before the first vim.pack.add(): with a lockfile, that first
-- call installs every missing plugin at once.
vim.api.nvim_create_autocmd("PackChanged", {
  group = vim.api.nvim_create_augroup("user_pack_builds", { clear = true }),
  callback = function(ev)
    local data = ev.data
    local build = builds[data.spec.name]
    if build and (data.kind == "install" or data.kind == "update") then
      build(data)
    end
  end,
})

require("plugins.colorscheme")
require("plugins.ui")
require("plugins.editor")
require("plugins.coding")
require("plugins.lsp")
require("plugins.treesitter")
require("plugins.format")
require("plugins.lang")
