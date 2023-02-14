local opts = { noremap = true, silent = true }
local term_opts = { silent = true }

local keymap = vim.api.nvim_set_keymap

-- 検索ハイライト削除
keymap("n", "<esc><esc>", ":noh<cr><esc>", opts)

-- 数字インクリメント
keymap("n", "+", "<C-x>", opts)
keymap("n", "-", "<C-a>", opts)

-- ウィンドウ操作
keymap("n", "e", "<Nop>", opts)
keymap("n", "es", "<cmd><C-u>sp<cr>", opts)
keymap("n", "ev", "<cmd><C-u>vs<cr>", opts)
keymap("n", "ej", "<C-w>j", opts)
keymap("n", "ek", "<C-w>k", opts)
keymap("n", "eh", "<C-w>h", opts)
keymap("n", "el", "<C-w>l", opts)
keymap("n", "eb", "<cmd>tabnew<cr>", opts)
keymap("n", "ew", "<cmd>q<cr>", opts)
keymap("n", "eq", "<cmd>qa<cr>", opts)
keymap("n", "<S-q>", "<cmd>%bd<cr>", opts)

-- モード切り替え
keymap("i", "jk", "<esc>", opts)

-- 入力中のカーソル移動
keymap("i", "<C-k>", "<Up>", opts)
keymap("i", "<C-j>", "<Down>", opts)
keymap("i", "<C-l>", "<Right>", opts)
keymap("i", "<C-h>", "<Left>", opts)
