local add = MiniDeps.add
add({
  source = "https://github.com/catppuccin/nvim"
})

require("catppuccin").setup({
  background = {
    dark = "macchiato",
  },
  no_italic = true,
  integrations = {
    mini = {
      enabled = true,
      indentscope_color = "peach",
    }
  }
})
vim.cmd("colorscheme catppuccin")
