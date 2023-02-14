return {
  {
    "nvim-lualine/lualine.nvim",
    dependencies = {
      "lewis6991/gitsigns.nvim",
    },
    opts = function(_, opts)
      local function diff_source()
        local gitsigns = vim.b.gitsigns_status_dict
        if gitsigns then
          return {
            added = gitsigns.added,
            modified = gitsigns.changed,
            removed = gitsigns.removed,
          }
        end
      end
      return {
        options = {
          icons_enabled = true,
          theme = "auto",
          disabled_filetypes = { "lazy" },
        },
        sections = {
          lualine_a = { "mode" },
          lualine_b = {
            "branch",
            {
              "diff",
              source = diff_source,
              symbols = {
                added = " ",
                modified = "柳 ",
                removed = " ",
              },
            },
          },
          lualine_c = {
            {
              "filename",
              path = 1,
              file_status = true,
              shorting_target = 30,
              symbols = {
                modified = "[+]",
                readonly = "[-]",
                unnamed = "[Untitled]",
              },
            },
          },
          lualine_x = {
            {
              "diagnostics",
              source = { "nvim_diagnostic" },
              symbols = { error = " ", warn = " ", info = " " },
            },
            "encoding",
            "filetype",
          },
          lualine_y = { "progress" },
          lualine_z = { "location" },
        },
        inactive_sections = {
          lualine_a = {},
          lualine_b = {},
          lualine_c = {
            {
              "filename",
              path = 1,
              file_status = true,
            }
          },
          lualine_x = { "location" },
          lualine_y = {},
          lualine_z = {},
        },
        tabline = {},
      }
    end,
  },
}
