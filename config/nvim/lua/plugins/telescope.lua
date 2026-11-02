-- netrw完全無効化
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
local add = MiniDeps.add

add({
  source = "nvim-telescope/telescope.nvim",
  depends = {
    "nvim-lua/plenary.nvim",
    "nvim-telescope/telescope-ui-select.nvim",
  },
})
add({
  source = "nvim-lua/plenary.nvim",
  depends = { "nvim-telescope/telescope-fzf-native.nvim" },
})
add({
  source = "nvim-telescope/telescope-fzf-native.nvim",
  hooks = {
    post_install = function()
      vim.system({ "make" }):wait()
    end,
    post_checkout = function()
      vim.system({ "make" }):wait()
    end,
  },
})
add({
  source = "nvim-telescope/telescope-file-browser.nvim",
})

MiniDeps.later(function()
  local telescope = require("telescope")
  local builtin = require("telescope.builtin")
  local telescope_theme = require("plugins.telescope_theme")

  -- file_browser設定を安全に構築
  local file_browser_config = {
    theme = telescope_theme.theme.theme,
    hijack_netrw = true,
  }

  -- 拡張機能がロード済みの場合のみキーマップを設定
  pcall(function()
    local fb_actions = require("telescope").extensions.file_browser.actions
    file_browser_config.mappings = {
      i = {
        ["<A-c>"] = fb_actions.create,
        ["<A-d>"] = fb_actions.remove,
        ["<A-r>"] = fb_actions.rename,
        ["<A-y>"] = fb_actions.copy,
        ["<A-h>"] = fb_actions.goto_parent_dir,
      },
      n = {
        ["c"] = fb_actions.create,
        ["d"] = fb_actions.remove,
        ["r"] = fb_actions.rename,
        ["y"] = fb_actions.copy,
        ["h"] = fb_actions.goto_parent_dir,
      },
    }
  end)

  telescope.setup({
  extensions = {
    ["ui-select"] = require("telescope.themes").get_dropdown(),
    ["file_browser"] = file_browser_config,
  },
  defaults = {
    layout_config = telescope_theme.height,
    mappings = {
      i = {
        ["<esc>"] = "close",
        ["<Leader>q"] = "close",
        ["<C-j>"] = "move_selection_next",
        ["<C-k>"] = "move_selection_previous",
      },
      n = {
        ["<esc>"] = "close",
        ["<Leader>q"] = "close",
        ["<C-j>"] = "move_selection_next",
        ["<C-k>"] = "move_selection_previous",
      },
    },
  },
  pickers = {
    find_files = {
      theme = telescope_theme.theme.theme,
      find_command = { "rg", "--files", "--hidden", "--no-ignore-vcs", "--glob", "!.git/*" },
    },
    live_grep = telescope_theme.theme,
    buffers = telescope_theme.theme,
    current_buffer_fuzzy_find = telescope_theme.theme,
    diagnostics = telescope_theme.theme,
    registers = telescope_theme.theme,
    oldfiles = telescope_theme.theme,
  }
})

  pcall(telescope.load_extension, "fzf")
  pcall(telescope.load_extension, "ui-select")
  pcall(telescope.load_extension, "file_browser")

  -- キーマップはlua/config/keymaps.luaに統合されました
end)
