local M = {}

M.theme = { theme = "ivy" }
M.height = { height = 0.4 }
M.git = { height = 0.6 }
local ok, themes = pcall(require, "telescope.themes")
M.themes = ok and themes or nil

function M.get_theme_with_height(height)
  return M.themes.get_ivy({ layout_config = { height = height or M.git.height } })
end

return M
