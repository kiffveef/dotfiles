local add = MiniDeps.add

add({
  source = "amitds1997/remote-nvim.nvim",
  depends = { "nvim-telescope/telescope.nvim" },
})

require("remote-nvim").setup({
  default_connections = {
    {
      name = "glace",
      ssh = "root@192.168.153.128",
    },
  },
  telescope_integration = true,
  custom_pickers = {
    files = {
      prompt_title = "Glace Remote Files",
      layout_strategy = "vertical",
      sorting_strategy = "ascending",
    },
  },
})

-- Telescope拡張としてremote-nvimを明示的にロード
pcall(function()
  require("telescope").load_extension("remote_nvim")
end)

