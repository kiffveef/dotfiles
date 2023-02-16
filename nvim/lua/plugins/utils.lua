return {
  {
    "windwp/nvim-autopairs",
    opts = {
      disable_filetype = {
        "TelescopePrompt",
        "vim",
      },
    },
  },
  {
    "numToStr/Comment.nvim",
    config = function()
      vim.keymap.set("n", "<C-_>", function()
          return vim.v.count == 0
              and "<Plug>(comment_toggle_linewise_current)"
              or "<Plug>(comment_toggle_linewise_count)"
      end, { expr = true })
      vim.keymap.set("x", "<C-_>", "<Plug>(comment_toggle_linewise_visual)")
    end,
  },
  {
    "machakann/vim-sandwich",
  },
  {
    "RRethy/vim-illuminate",
    event = { "BufReadPost", },
    config = function()
      require("illuminate").configure({
        delay = 100,
      })
    end,
  },
  {
    "junegunn/vim-easy-align",
    config = function()
      vim.keymap.set("x", "ga", "<Plug>(EasyAlign)")
      vim.keymap.set("n", "ga", "<Plug>(EasyAlign)")
    end
  },
  {
    "lukas-reineke/indent-blankline.nvim",
    event = { "BufReadPost", "BufNewFile" },
    opts = {
      -- char = "▏",
      char = "│",
      filetype_exclude = { "help", "Trouble", "lazy", "NeogitStatus" },
      show_trailing_blankline_indent = false,
      show_current_context = false,
    },
  },
  {
    "echasnovski/mini.indentscope",
    version = false, -- wait till new 0.7.0 release to put it back on semver
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      -- symbol = "▏",
      symbol = "│",
      draw = { delay = 20 },
      options = { try_as_border = true },
    },
    config = function(_, opts)
      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "help", "Trouble", "lazy", "mason" },
        callback = function()
          vim.b.miniindentscope_disable = true
        end,
      })
      require("mini.indentscope").setup(opts)
    end,
  },
  {
    "glidenote/memolist.vim",
    dependencies = { "previm/previm" },
    config = function()
      local rc = require("rc.local")
      vim.g.memolist_path = rc.memodir
      vim.g.memolist_memo_suffix = "md"
      vim.g.memolist_template_dir_path = vim.env.XDG_CONFIG_HOME .. "/templates/memo"
      vim.g.previm_open_cmd = rc.browser_exe
      vim.g.previm_wsl_mode = 1
      vim.api.nvim_set_keymap("n",  "<leader>mn", ":MemoNew<cr>", { noremap = true, silent = true })
      -- vim.api.nvim_set_keymap("n",  "<leader>ml", ":MemoList<cr>", { noremap = true, silent = true })
    end,
  }
}
