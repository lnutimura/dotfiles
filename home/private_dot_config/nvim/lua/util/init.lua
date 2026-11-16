local M = {}

--- Expand a GitHub "owner/repo" into a `vim.pack` source URL.
---@param repo string
---@return string
function M.gh(repo)
  return "https://github.com/" .. repo
end

return M
