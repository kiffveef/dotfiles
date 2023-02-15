return {
  {
    "rebelot/kanagawa.nvim",
    lazy = false,
    priority = 1000,
    opts = {
      commentStyle = { italic = false },
      functionStyle = { bold = true, italic = false },
      keywordStyle = { italic = false },
      statementStyle = { italic = false },
      typeStyle = { bold = true, italic = false },
      variablebuiltinStyle = { italic = false },
    },
    config = function(_, opts)
      require("kanagawa").setup(opts)
      vim.cmd([[colorscheme kanagawa]])
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter",
    version = false,
    build = ":TSUpdate",
    event = { "BufRead", "BufNewFile", "InsertEnter" },
    dependencies = {
      { "yioneko/nvim-yati" },
      { "RRethy/nvim-treesitter-endwise" },
    },
    opts = {
      ensure_installed = {
        "lua",
        "vim",
        "markdown",
        "markdown_inline",
        "yaml",
        "toml",
        "json",
        "gitignore",
        "gitcommit",
        "git_rebase",
        "bash",
        "fish",
        "dockerfile",
        "dot",
        "ruby",
      },
      sync_install = false,
      auto_install = true,
      highlight = {
        enable = true,
        additional_vim_regex_highlighting = false,
      },
      yati = {
        enable = true,
        default_lazy = true,
      },
      indent = {
        enable = false,
      },
      endwise = {
        enable = true,
      },
    },
    config = function(_, opts)
      require("nvim-treesitter.configs").setup(opts)
    end
  },
}

