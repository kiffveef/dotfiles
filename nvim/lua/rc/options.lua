local options = {
-- エンコード
  encoding = "utf-8",
  termencoding = "utf-8",
-- タブ
  smarttab = true,
  expandtab = true,
  tabstop = 2,
  softtabstop = 2,
  shiftwidth = 2,
  shiftround = true,
-- インデント
  autoindent = true,
  smartindent = true,
-- 改行
  list = true,
  listchars = "tab:›-,trail:-,nbsp:%,extends:›,precedes:‹",
-- 表示
  number = true,
  relativenumber = false,
  numberwidth = 4,
  cursorline = true,
  cursorcolumn = false,
  modelines = 2,
  showtabline = 2,
  wrap = true,
  pumheight = 10,
  scrolloff = 5,
  showmatch = true,
  matchtime = 2,
-- 一時ファイル
  autoread = true,
  backup = false,
  writebackup = false,
  swapfile = false,
  undofile = true,
  undodir = vim.env.HOME .. "/.local/undo",
-- 検索
  ignorecase = true,
  smartcase = true,
  wrapscan = true,
  incsearch = true,
-- クリップボード
  clipboard = "unnamedplus",
-- 矩形選択
  virtualedit = "block",
-- 補完
  completeopt = { "menuone", "noinsert" }
}

vim.opt.shortmess:append("c")

for k, v in pairs(options) do
  vim.opt[k] = v
end

vim.cmd("set whichwrap=b,s,h,l,<,>,~,[,]")
vim.cmd("set formatoptions=crMmopl")
-- カーソルをIバーに変更
vim.cmd("set guicursor+=c-v-ve:ver10")
