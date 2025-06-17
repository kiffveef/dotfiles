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

local opts = {
  theme = { theme = "ivy" },
  height = { height = 0.4 },
}
local telescope = require("telescope")
local builtin = require("telescope.builtin")

telescope.setup({
  extensions = {
    ["ui-select"] = { require("telescope.themes").get_dropdown() },
    ["file_browser"] = {
      theme = opts.theme.theme,
      hijack_netrw = true,
      mappings = {
        i = {
          ["<A-c>"] = telescope.extensions.file_browser.actions.create,
          ["<A-d>"] = telescope.extensions.file_browser.actions.remove,
          ["<A-r>"] = telescope.extensions.file_browser.actions.rename,
          ["<A-y>"] = telescope.extensions.file_browser.actions.copy,
        },
        n = {
          ["c"] = telescope.extensions.file_browser.actions.create,
          ["d"] = telescope.extensions.file_browser.actions.remove,
          ["r"] = telescope.extensions.file_browser.actions.rename,
          ["y"] = telescope.extensions.file_browser.actions.copy,
        },
      },
    },
  },
  defaults = {
    layout_config = opts.height,
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
    find_files = opts.theme,
    live_grep = opts.theme,
    buffers = opts.theme,
    current_buffer_fuzzy_find = opts.theme,
    diagnostics = opts.theme,
    registers = opts.theme,
  }
})

pcall(telescope.load_extension, "fzf")
pcall(telescope.load_extension, "ui-select")
pcall(telescope.load_extension, "file_browser")

vim.keymap.set("n", "<Leader>ff", builtin.find_files, { desc = "Search Files" })
vim.keymap.set("n", "<Leader>fg", builtin.live_grep, { desc = "Search by Grep" })
vim.keymap.set("n", "<Leader>fb", builtin.buffers, { desc = "Find existing buffers" })
vim.keymap.set("n", "<Leader>f/", builtin.current_buffer_fuzzy_find,  { desc = "Fuzzy find in current buffers" })
vim.keymap.set("n", "<Leader>fd", builtin.diagnostics, { desc = "Search Diagnostics" })
vim.keymap.set("n", "<Leader>fr", builtin.registers, { desc = "Search Registers" })
vim.keymap.set("n", "<Leader>fw", telescope.extensions.file_browser.file_browser, { desc = "File browser" })
