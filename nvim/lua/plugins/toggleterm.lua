return {
  -- cf. https://github.com/folke/dot/blob/7d696ae93ca6f434d729c9c0ac9efa780ee5026b/config/nvim/lua/config/plugins/toggleterm.lua
  "akinsho/toggleterm.nvim",
  keys = "<leader>t",
  config = function()
    require("toggleterm").setup({
      size = 30,
      hide_numbers = true,
      open_mapping = [[<leader>t]],
      shade_filetypes = {},
      shade_terminals = false,
      shading_factor = 0.3,
      start_in_insert = true,
      presist_size = true,
      direction = "horizontal",
    })
    vim.cmd([[tnoremap <esc><esc> <C-\><C-N>]])
  end,
}
