local add = MiniDeps.add

add({
  source = "nvim-treesitter/nvim-treesitter",
  hooks = {
    post_checkout = function()
      vim.cmd.TSUpdate()
    end,
    post_install = function()
      vim.cmd.TSUpdate()
    end,
  },
})

-- プラグイン読み込み後に設定を実行
vim.schedule(function()
  local ok, configs = pcall(require, "nvim-treesitter.configs")
  if not ok then
    return
  end

  configs.setup({
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
      "javascript",
      "typescript",
      "dockerfile",
      "json",
      "yaml",
      "toml",
      "markdown",
      "markdown_inline",
    },
    highlight = { enable = true },
  })
end)
