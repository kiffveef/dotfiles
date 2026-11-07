-- ========================================
-- オプション設定
-- ========================================

local options = {
  title = true,
  swapfile = false,
  undofile = true,
  updatetime = 500,
  timeoutlen = 300,
  writebackup = false,
  clipboard = "unnamedplus",
  mouse = "a",
  smartcase = true,
  ignorecase = true,
  number = true,
  expandtab = true,
  shiftround = true,
  shiftwidth = 2,
  softtabstop = 2,
  tabstop = 2,
  cursorline = true,
  signcolumn = "yes",
  scrolloff = 20,
  whichwrap = "b,s,h,l,<,>,[,],~",
  -- 既定値と同じだがmini.basicsがnowrapにするため明示する
  wrap = true,
  linebreak = true,
  breakindent = true,
}

-- オプションを適用
for k, v in pairs(options) do
  vim.opt[k] = v
end

-- shortmessを追加設定
vim.opt.shortmess:append("aAIFOtTc")

-- ========================================
-- コメント継続の制御
-- ========================================

-- コメント行で改行してもコメントを継続しない
vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("config_formatoptions", { clear = true }),
  pattern = "*",
  callback = function()
    vim.opt_local.formatoptions:remove({ "c", "r", "o" })
  end,
})

-- ========================================
-- Windows clipboard integration
-- ========================================

-- executable()はWSLのPATH(/mnt/c配下)を走査して起動が約40ms遅れるため、WSL判定だけで決める
if vim.fn.has("wsl") == 1 then
  vim.g.clipboard = {
    name = "win32yank",
    copy = {
      ["+"] = "win32yank.exe -i --crlf",
      ["*"] = "win32yank.exe -i --crlf",
    },
    paste = {
      ["+"] = "win32yank.exe -o --lf",
      ["*"] = "win32yank.exe -o --lf",
    },
    cache_enabled = 0,
  }

  -- 既定のexplorer.exeはURLを開いても終了コード1を返しgXがエラー通知するため、rundll32で開く
  -- 保存時リロードで二重に包まないようフラグで一度だけ差し替える
  if not vim.g.config_ui_open_wrapped then
    vim.g.config_ui_open_wrapped = true
    local ui_open = vim.ui.open
    vim.ui.open = function(path, opt)
      opt = opt or {}
      opt.cmd = opt.cmd or { "rundll32.exe", "url.dll,FileProtocolHandler" }
      return ui_open(path, opt)
    end
  end
end
