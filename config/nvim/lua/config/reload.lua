-- lua/config/reload.lua: *.lua保存時に自動でnvimを再読み込み

local M = {}

M.setup = function()
  vim.api.nvim_create_autocmd("BufWritePost", {
    pattern = "*.lua",
    callback = function(args)
      -- 設定ファイル保存時のみ再読み込み
      local file = args.file
      if file:find(vim.fn.stdpath("config"), 1, true) == 1 then
        dofile(file)
        -- 通知を無効化(Press ENTERプロンプトを回避)
        -- vim.notify("Reloaded: " .. file, vim.log.levels.INFO)
      end
    end,
  })
end

return M
