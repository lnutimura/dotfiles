-- lualine components, ported from LazyVim's lazyvim.util.lualine.
local M = {}

--- Render `text` inside a lualine component with the colors of `hl_group`.
---@param component table lualine component (`self` in a function component)
---@param text string
---@param hl_group? string
---@return string
local function format(component, text, hl_group)
  text = text:gsub("%%", "%%%%")
  if not hl_group or hl_group == "" then
    return text
  end
  component.hl_cache = component.hl_cache or {}
  local lualine_hl = component.hl_cache[hl_group]
  if not lualine_hl then
    local utils = require("lualine.utils.utils")
    local gui = vim.tbl_filter(function(x)
      return x
    end, {
      utils.extract_highlight_colors(hl_group, "bold") and "bold",
      utils.extract_highlight_colors(hl_group, "italic") and "italic",
    })
    lualine_hl = component:create_hl({
      fg = utils.extract_highlight_colors(hl_group, "fg"),
      gui = #gui > 0 and table.concat(gui, ",") or nil,
    }, "PrettyPath_" .. hl_group)
    component.hl_cache[hl_group] = lualine_hl
  end
  return component:format_hl(lualine_hl) .. text .. component:get_default_hl()
end

---@class util.lualine.PrettyPathOpts
---@field directory_hl? string
---@field filename_hl? string
---@field modified_hl? string
---@field modified_sign? string
---@field readonly_icon? string

--- The buffer path relative to the cwd: directory, then the file name
--- highlighted by its modified state, then a read-only marker.
---@param opts? util.lualine.PrettyPathOpts
function M.pretty_path(opts)
  opts = vim.tbl_extend("force", {
    directory_hl = "",
    filename_hl = "Bold",
    modified_hl = "MatchParen",
    modified_sign = "",
    readonly_icon = " 󰌾 ",
  }, opts or {})

  return function(self)
    local path = vim.fn.expand("%:p") --[[@as string]]
    if path == "" then
      return ""
    end

    local cwd = vim.uv.fs_realpath(vim.uv.cwd() or "") or ""
    if cwd ~= "" and path:find(cwd .. "/", 1, true) == 1 then
      path = path:sub(#cwd + 2)
    end

    local parts = vim.split(path, "/")
    local name = parts[#parts]
    if vim.bo.modified then
      name = format(self, name .. opts.modified_sign, opts.modified_hl)
    else
      name = format(self, name, opts.filename_hl)
    end

    local dir = ""
    if #parts > 1 then
      dir = format(self, table.concat(parts, "/", 1, #parts - 1) .. "/", opts.directory_hl)
    end

    local readonly = vim.bo.readonly and format(self, opts.readonly_icon, opts.modified_hl) or ""
    return dir .. name .. readonly
  end
end

return M
