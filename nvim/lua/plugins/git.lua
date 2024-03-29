return {
  {
    "timUntersberger/neogit",
    dependencies = {
      {
        "nvim-lua/plenary.nvim",
        lazy = true,
      },
    },
    -- config = function()
    --   require("neogit").setup({
    --     integrations = { diffview = true },
    --   })
    -- end,
    -- init = function()
    --   vim.keymap.set("n", "<leader>gg", "<cmd>Neogit<cr>")
    -- end,
  },
  {
    "lewis6991/gitsigns.nvim",
    config = function()
      require("gitsigns").setup({
        attach_to_untracked = true,
        current_line_blame_opts = {
          virt_text = true,
          virt_text_pos = "eol",
          delay = 400,
          ignore_whitespace = false,
        },
        current_line_blame_formatter = "(<author>)<author_time:%Y-%m-%d>: <summary>",
        on_attach = function(bufnr)
          local gs = package.loaded.gitsigns

          local function map(mode, l, r, opts)
            opts = opts or {}
            opts.buffer = bufnr
            vim.keymap.set(mode, l, r, opts)
          end

          -- Navigation
          map("n", "]c", function()
            if vim.wo.diff then return "]c" end
            vim.schedule(function() gs.next_hunk() end)
            return "<Ignore>"
          end, {expr=true})

          map("n", "[c", function()
            if vim.wo.diff then return "[c" end
            vim.schedule(function() gs.prev_hunk() end)
            return "<Ignore>"
          end, {expr=true})

          -- Actions
          map({"n", "v"}, "<leader>hs", "<cmd>Gitsigns stage_hunk<cr>")
          map({"n", "v"}, "<leader>hr", "<cmd>Gitsigns reset_hunk<cr>")
          map("n", "<leader>hS", gs.stage_buffer)
          map("n", "<leader>hu", gs.undo_stage_hunk)
          map("n", "<leader>hR", gs.reset_buffer)
          map("n", "<leader>hp", gs.preview_hunk)
          map("n", "<leader>hb", function() gs.blame_line{full=true} end)
          map("n", "<leader>tb", gs.toggle_current_line_blame)
          map("n", "<leader>hd", gs.diffthis)
          map("n", "<leader>hD", function() gs.diffthis("~") end)
          map("n", "<leader>td", gs.toggle_deleted)

          -- Text object
          map({"o", "x"}, "ih", ":<C-U>Gitsigns select_hunk<cr>")
        end
      })
    end,
  },
  {
    "sindrets/diffview.nvim",
    cmd = {
      "DiffviewOpen",
      "DiffviewClose",
      "DiffviewToggleFiles",
      "DiffviewFocusFiles",
    },
    config = function()
      require("diffview").setup()
    end
  }
}
