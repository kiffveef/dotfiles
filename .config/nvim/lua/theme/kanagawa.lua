local add = MiniDeps.add
add({
  source = "https://github.com/rebelot/kanagawa.nvim"
})

require("kanagawa").setup({
  commentStyle = { italic = false },
  keywordStyle = { italic = false },
  functionStyle = { italic = false },
})

vim.cmd("colorscheme kanagawa-wave")
