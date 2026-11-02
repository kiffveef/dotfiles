
local add = MiniDeps.add
add({ source = "gbprod/yanky.nvim",
  depends = { "nvim-telescope/telescope.nvim" },
})

require("yanky").setup({
  highlight = {
    on_put = true,
    on_yank = true,
    timer = 200,
  },
  ring = {
    history_length = 100,
    storage = "shada",
    sync_with_numbered_registers = true,
  },
  picker = {
    select = { action = nil },
    telescope = {
      use_default_mappings = true,
    },
  },
  system_clipboard = {
    sync_with_clipboard = false,
    register_sync = false,
  },
})

-- キーマップはlua/config/keymaps.luaに統合されました

-- OSC52連携（yank時に自動でクリップボード連携）
local has_osc52, osc52 = pcall(require, "osc52")
if has_osc52 then
  vim.api.nvim_create_autocmd("TextYankPost", {
    callback = function()
      if vim.v.event.operator == 'y' and vim.v.event.regname == '' then
        osc52.copy(vim.fn.getreg('0'))
      end
    end,
  })
end
