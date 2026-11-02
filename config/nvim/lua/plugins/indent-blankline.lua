-- lua/plugins/indent-blankline.lua: インデントガイド用プラグイン設定
local add = MiniDeps.add

add("lukas-reineke/indent-blankline.nvim")

vim.api.nvim_set_hl(0, "IndentBlanklineIndent1", { fg = "#E06C75" })
vim.api.nvim_set_hl(0, "IndentBlanklineIndent2", { fg = "#E5C07B" })
vim.api.nvim_set_hl(0, "IndentBlanklineIndent3", { fg = "#98C379" })
vim.api.nvim_set_hl(0, "IndentBlanklineIndent4", { fg = "#56B6C2" })
vim.api.nvim_set_hl(0, "IndentBlanklineIndent5", { fg = "#61AFEF" })
vim.api.nvim_set_hl(0, "IndentBlanklineIndent6", { fg = "#C678DD" })

require("ibl").setup({
  indent = {
    char = "│",
    highlight = {
      "IndentBlanklineIndent1",
      "IndentBlanklineIndent2",
      "IndentBlanklineIndent3",
      "IndentBlanklineIndent4",
      "IndentBlanklineIndent5",
      "IndentBlanklineIndent6",
    },
  },
  scope = { enabled = true },
  whitespace = { remove_blankline_trail = false },
})

