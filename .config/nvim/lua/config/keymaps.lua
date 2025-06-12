local opts = { noremap = true, silent = true }
local term_opts = { silent = true }

local keymap = vim.api.nvim_set_keymap

-- ; と : を入れ替え
keymap("n", ";", ":", opts)

-- 検索ハイライトOFF
keymap("n", "<Esc><Esc>", ":<C-u>set nohlsearch<Return>", opts)

-- インサートモード離脱
keymap("i", "jk", "<Esc>", opts)
keymap("i", "jj", "<Esc>", opts)
keymap("i", "kj", "<Esc>", opts)

-- スペース挿入
keymap("i", ",", ",<Space>", opts)

-- インサートモード中のカーソル移動
keymap("i", "<C-k>", "<Up>", opts)
keymap("i", "<C-j>", "<Down>", opts)
keymap("i", "<C-l>", "<Right>", opts)
keymap("i", "<C-h>", "<Left>", opts)

vim.keymap.set("c", "<c-n>", function()
  return vim.fn.wildmenumode() == 1 and "<c-n>" or "<down>" end,
  {expr = true, desc = "Select next completion item"})
vim.keymap.set("c", "<c-p>", function()
  return vim.fn.wildmenumode() == 1 and "<c-p>" or "<up>" end,
  {expr = true, desc = "Select previous completion item"})
vim.keymap.set('n', '<space>q', function()
  if not pcall(vim.cmd.tabclose) then
    vim.cmd.quit()
  end
end, { desc = 'Quit current tab or window' })
