pcall(function() vim.loader.enable() end)

-- leaderキーを最初に設定（プラグイン読み込み前に必須）
vim.g.mapleader = " "

_G.Config = {
  path_package = vim.fn.stdpath("data") .. "/site/",
  path_source = vim.fn.stdpath("config") .. "/lua/",
}

vim.api.nvim_create_user_command(
  "InitLua",
  function()
    vim.cmd.edit(vim.fn.stdpath("config") .. "/init.lua")
  end,
  {}
)

local mini_path = Config.path_package .. "pack/deps/start/mini.nvim"
if not vim.uv.fs_stat(mini_path) then
  vim.cmd([[echo "Installing 'mini.nvim'" | redraw]])
  local clone_cmd = { "git", "clone", "--filter=blob:none", "https://github.com/echasnovski/mini.nvim", mini_path }
  vim.fn.system(clone_cmd)
end
require("mini.deps").setup({ path = { package = Config.path_package } })

local add, now, later = MiniDeps.add, MiniDeps.now, MiniDeps.later
local source = function(path) dofile(Config.path_source .. path) end

now(function()
  -- colorscheme
  source("theme/kanagawa.lua")

  -- *.lua保存時に自動で再読み込み
  pcall(function() require("config.reload").setup() end)
  source("config/options.lua")

  -- IME 自動制御
  pcall(function() require("config.ime").setup() end)

  -- mini.nvimプラグインを先に読み込み
  source("plugins/mini.lua")

  source("plugins/yazi.lua")

  -- MiniMiscのカーソル復元を有効化
  local ok, MiniMisc = pcall(require, "mini.misc")
  if ok and MiniMisc and type(MiniMisc.setup_restore_cursor) == "function" then
    MiniMisc.setup_restore_cursor()
  end
  vim.opt.laststatus = 3
  vim.opt.cmdheight = 0
  vim.api.nvim_create_autocmd({ "RecordingEnter", "CmdlineEnter" }, {
    pattern = "*",
    callback = function()
      vim.opt.cmdheight = 1
    end,
  })
  vim.api.nvim_create_autocmd("RecordingLeave", {
    pattern = "*",
    callback = function()
      vim.opt.cmdheight = 0
    end,
  })
  vim.api.nvim_create_autocmd("CmdlineLeave", {
    pattern = "*",
    callback = function()
      if vim.fn.reg_recording() == "" then
        vim.opt.cmdheight = 0
      end
    end,
  })
  source("plugins/notify.lua")

  source("plugins/treesitter.lua")

  source("plugins/logline.lua")
end)

later(function()
  source("plugins/telescope.lua")

  -- clipboard (yanky only)
  source("plugins/yanky.lua")

  -- Japanese text motion with BudouX
  source("plugins/budouxify.lua")

  -- キーマップ (プラグイン読み込み後に実行)
  source("config/keymaps.lua")

  -- LSP環境
  source("plugins/lsp.lua")

  source("plugins/vimdoc-ja.lua")

  source("plugins/indent-blankline.lua")
  source("plugins/floaterm.lua")

  source("plugins/memo.lua")

  -- remote-nvim.nvim 設定
  source("plugins/remote-nvim.lua")
end)
