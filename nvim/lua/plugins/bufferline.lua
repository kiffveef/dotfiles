return {
  {
    "akinsho/bufferline.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    event = { "BufRead" },
    opts = function(_, opts)
      return {
        options = {
          mode = "tabs",
          separator_style = 'thin',
          always_show_bufferline = true,
          show_buffer_close_icons = false,
          show_close_icon = false,
          color_icons = true
        },
        highlights = {
          tab_selected = {
            bold = true,
            italic = false,
          },
          buffer_selected = {
            bold = true,
            italic = false,
          },
        },
      }
    end,
    keys = {
      { "<C-n>", "<cmd>BufferLineCycleNext<cr>", mode = { "n" } },
      { "<C-p>", "<cmd>BufferLineCyclePrev<cr>", mode = { "n" } },
    },
  },
}
