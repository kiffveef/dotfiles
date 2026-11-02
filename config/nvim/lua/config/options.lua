-- ========================================
-- オプション設定
-- ========================================

local options = {
  encoding = "utf-8",
  fileencoding = "utf-8",
  title = true,
  backup = false,
  swapfile = false,
  undofile = true,
  updatetime = 500,
  timeoutlen = 300,
  lazyredraw = true,
  redrawtime = 10000,
  writebackup = false,
  backupskip = { "/tmp/*", "/private/tmp/*" },
  clipboard = "unnamedplus",
  mouse = "a",
  showtabline = 0,
  smartcase = true,
  ignorecase = true,
  number = true,
  expandtab = true,
  shiftround = true,
  shiftwidth = 2,
  softtabstop = 2,
  tabstop = 2,
  cursorline = true,
  relativenumber = false,
  signcolumn = "yes",
  scrolloff = 10,
  whichwrap = "b,s,h,l,<,>,[,],~",
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
  pattern = "*",
  callback = function()
    vim.opt_local.formatoptions:remove({ "c", "r", "o" })
  end,
})

-- ========================================
-- Windows clipboard integration
-- ========================================

local win32yank = vim.fn.expand("~/workspace/bin/win32yank.exe")
vim.g.clipboard = {
  name = "win32yank",
  copy = {
    ["+"] = win32yank .. " -i --crlf",
    ["*"] = win32yank .. " -i --crlf",
  },
  paste = {
    ["+"] = win32yank .. " -o --lf",
    ["*"] = win32yank .. " -o --lf",
  },
  cache_enabled = 0,
}
