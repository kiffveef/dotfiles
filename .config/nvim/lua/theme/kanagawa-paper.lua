local add = MiniDeps.add
add({
  source = "https://github.com/thesimonho/kanagawa-paper.nvim"
})

require("kanagawa-paper").setup({
  styles = {
    comment = { italic = false },
    functions = { italic = false },
    keyword = { italic = false },
    statement = { italic = false },
    type = { italic = false },
  }
})

vim.cmd("colorscheme kanagawa-paper-ink")
