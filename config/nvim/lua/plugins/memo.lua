local add = MiniDeps.add
add("glidenote/memolist.vim")

-- memoコマンドのパスを通す（必要に応じて）
-- vim.g.memo_path = vim.fn.expand("~/memo")
-- vim.g.memolist_path = vim.fn.expand("~/memo")
-- vim.g.memolist_memo_suffix = ".md"

-- memolist.vimの設定例
vim.g.memolist_memo_suffix = ".md"
vim.g.memolist_path = vim.fn.expand("/mnt/c/Users/harue.inoue/_workspace/memo/")
vim.g.memolist_template_dir_path = vim.fn.expand("~/workspace/memo/template_daily")

-- キーマップはlua/config/keymaps.luaに統合されました

-- memoコマンドのパスが通っていない場合は、~/.local/bin等にインストールし、PATHを通してください。
-- 詳細なカスタマイズは https://github.com/mattn/memo や https://github.com/glidenote/memolist.vim を参照。
