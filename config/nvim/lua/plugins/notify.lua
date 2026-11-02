local add = MiniDeps.add

add({
  source = "rcarriga/nvim-notify",
  depends = { "nvim-telescope/telescope.nvim", "nvim-lua/plenary.nvim" },
})

require("notify").setup({
  stages = "fade_in_slide_out",
  timeout = 5000,
  render = "compact",
  max_width = 60,
  max_height = 10,
})

vim.notify = require("notify")

-- Telescope拡張としてnotifyをロード
pcall(function()
  require("telescope").load_extension("notify")
end)

-- キーマップはlua/config/keymaps.luaに統合されました
