local add = MiniDeps.add
add({source = "https://github.com/AlexvZyl/nordic.nvim"})

require("nordic").setup({
  italic_comments = false,
})

vim.cmd("colorscheme nordic")
