local add = MiniDeps.add

add({
  source = "https://github.com/nvim-treesitter/nvim-treesitter",
  hooks = {
    post_checkout = function()
      vim.cmd.TSUpdate()
    end
  },
})

require("nvim-treesitter.configs").setup({
  ensure_installed = {
    "lua",
    "vim",
    "bash",
    "git_config",
    "git_rebase",
    "gitattributes",
    "gitcommit",
    "gitignore",
    "ruby",
    "dockerfile",
    "yaml",
    "toml",
  },
  highlight = { enable = true },
})
