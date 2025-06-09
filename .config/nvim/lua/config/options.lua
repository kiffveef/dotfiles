local options = {
  encoding = "utf-8",
  fileencoding = "utf-8",
  title = true,
  backup = false,
  swapfile = false,
  undofile = true,
  updatetime = 300,
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
}

vim.opt.shortmess:append("c")
vim.opt.clipboard:append("unnamedplus,unnamed")

for k, v in pairs(options) do
  vim.opt[k] = v
end
