return {
  "nvim-telescope/telescope.nvim",
  dependencies = {
    {
      "nvim-lua/plenary.nvim",
      lazy = true,
    },
    {
      "nvim-telescope/telescope-frecency.nvim",
      requires = "kkharji/sqlite.lua",
    },
    "kkharji/sqlite.lua",
    "nvim-telescope/telescope-file-browser.nvim",
    {
      "nvim-telescope/telescope-fzf-native.nvim",
      build = "make",
    },
    "cljoly/telescope-repo.nvim",
  },
  opts = {
    theme = { theme = "ivy" },
    height = { height = 0.4 },
  },
  config = function(_, opts)
    local telescope = require("telescope")
    local fw_actions = telescope.extensions.file_browser.actions
    telescope.setup({
      defaults = {
        file_ignore_patterns = {
          ".bundle",
          ".git/HEAD",
          ".git/index",
          ".git/object",
          ".git/packed-refs",
          ".git/refs",
          "node_modules",
          "log",
          "_files"
        },
        layout_config = opts.height,
        mappings = {
        -- cf. https://github.com/nvim-telescope/telescope.nvim/blob/master/lua/telescope/mappings.lua
          i = {
            ["<esc>"] = "close",
            ["<leader>q"] = "close",
            ["<C-j>"] = "move_selection_next",
            ["<C-k>"] = "move_selection_previous",
            ["<C-b>"] = "select_tab",
          },
          n = {
            ["<esc>"] = "close",
            ["<leader>q"] = "close",
            ["<C-j>"] = "move_selection_next",
            ["<C-k>"] = "move_selection_previous",
            ["<C-b>"] = "select_tab",
          },
        },
      },
      pickers = {
        find_files = opts.theme,
        live_grep  = opts.theme,
        buffers    = opts.theme,
        registers  = opts.theme,
      },
      extensions = {
        frecency = {
          db_root = vim.env.XDG_CONFIG_HOME .. "/nvim",
          ignore_patterns = { "*/tmp/*", "*/log/*", ".linuxbrew/*" },
          limit = 200,
        },
        file_browser = {
          theme = "ivy",
          hijack_netrw = true,
          cwd_to_path = true,
          mappings = {
            ["n"] = {
              ["N"] = fw_actions.create,
              ["h"] = fw_actions.goto_parent_dir,
            },
          },
        },
        fzf = {
          fuzzy = true,
          override_file_sorter = true,
          case_mode = "smart_case",
        },
        repo = {
          search_dirs = {
            vim.fn.stdpath("data") .. "/site/pack",
            vim.env.HOME .. "/workspace",
          },
        },
      },
    })
    telescope.load_extension("frecency")
    telescope.load_extension("file_browser")
    telescope.load_extension("fzf")
    telescope.load_extension("repo")
  end,
  keys = function(opts)
    local actions = require("telescope.actions")
    local builtin = require("telescope.builtin")
    local function telescope_buffer_dir()
      return vim.fn.expand("%:p:h")
    end
    return {
      {
        -- All files list
        mode = { "n" }, "<Space>ff", function()
          builtin.find_files({
            no_ignore = false,
            hidden = true,
          })
        end
      },
      {
        -- List of files in current directory
        mode = { "n" }, "<leader>ff", function()
          builtin.find_files({
            cwd = telescope_buffer_dir(),
            no_ignore = false,
            hidden = true,
          })
        end
      },
      { mode = { "n" }, "<Space>fr", function() builtin.live_grep() end },
      { mode = { "n" }, "<Space>fb", function() builtin.buffers() end },
      { mode = { "i", "n" }, "<leader>y", function() builtin.registers() end },
      {
        mode = { "n" }, "<leader>fw", function()
          require("telescope").extensions.file_browser.file_browser({
            path = "%:p:h",
            cwd = telescope_buffer_dir(),
            respect_gitignore = false,
            hidden = true,
            grouped = true,
            previewer = false,
            initial_mode = "insert",
            layout_config = opts.height,
          })
        end
      },
      {
        -- Open mattn/memo dir
        mode = { "n" }, "<leader>ml", function()
          require("telescope").extensions.file_browser.file_browser({
            path = require("rc.local").memodir,
            cwd = telescope_buffer_dir(),
            respect_gitignore = false,
            hidden = true,
            grouped = true,
            previewer = false,
            initial_mode = "insert",
            layout_config = opts.height,
          })
        end
      },
      {
        mode = { "n" }, "<Space>fh", function()
          require("telescope").extensions.frecency.frecency(require("telescope.themes").get_ivy(opts.height))
        end
      },
      { mode = { "n" }, "<leader>fr", function()
          require("telescope").extensions.repo.list(require("telescope.themes").get_ivy(opts.height))
        end
      },
    }
  end,
}
