vim.loader.enable()

-- leaderキーを最初に設定(プラグイン読み込み前に必須)
vim.g.mapleader = " "

-- mini.depsがmini.nvimを管理できるようにpack/deps/start配下へclone
local path_package = vim.fn.stdpath("data") .. "/site/"
local mini_path = path_package .. "pack/deps/start/mini.nvim"
if not vim.uv.fs_stat(mini_path) then
  vim.cmd('echo "Installing `mini.nvim`" | redraw')
  local clone_cmd = {
    "git", "clone", "--filter=blob:none",
    "https://github.com/nvim-mini/mini.nvim", mini_path,
  }
  vim.fn.system(clone_cmd)
  vim.cmd("packadd mini.nvim | helptags ALL")
  vim.cmd('echo "Installed `mini.nvim`" | redraw')
end
require("mini.deps").setup({ path = { package = path_package } })

require("config.options")
-- mini.*のUIモジュールが読み込み時にkanagawaの配色を参照できるよう、カラースキームを含むplugins.luaを先に読む
require("config.plugins")
require("config.mini")
require("config.keymaps")
require("config.ime")

-- 保存時に再実行してよいのは副作用が冪等な設定ファイルだけ(プラグイン設定は再起動が必要)
local reloadable = {
  vim.fn.stdpath("config") .. "/lua/config/options.lua",
  vim.fn.stdpath("config") .. "/lua/config/keymaps.lua",
}

vim.api.nvim_create_autocmd("BufWritePost", {
  group = vim.api.nvim_create_augroup("config_reload", { clear = true }),
  pattern = "*.lua",
  callback = function(args)
    -- ~/.config/nvimはsymlinkなので、どちらのパスで編集しても一致するよう実体パスで比較
    local saved = vim.uv.fs_realpath(args.file)
    -- 実体がないと、同じく実体のないreloadableとnil同士で一致してdofile(nil)が走るため
    if not saved then
      return
    end
    for _, path in ipairs(reloadable) do
      if saved == vim.uv.fs_realpath(path) then
        dofile(saved)
        vim.notify("Reloaded: " .. vim.fn.fnamemodify(saved, ":t"))
        return
      end
    end
  end,
})
