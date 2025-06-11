local add = MiniDeps.add
add({
  source = "https://github.com/folke/tokyonight.nvim"
})

require("tokyonight").setup({
  styles = {
    comments = { italic = false },
    keywords = { italic = false },
    functions = { italic = false },
    variables = { italic = false },
  }
})

vim.cmd("colorscheme tokyonight-moon")
