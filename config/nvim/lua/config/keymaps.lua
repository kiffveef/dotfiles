-- ========================================
-- キーマップ設定
-- ========================================

-- 保存時にdofileで再実行されるため、ここには上書きで済む定義だけを置く
-- (jk/jj/kjのcomboは再登録すると重複するのでmini.luaに置いている)
-- mini.*はlater()で読み込まれるため、Mini*グローバルは実行時に参照する

-- ========================================
-- 基本キーマップ
-- ========================================

-- Shiftなしでコマンドラインに入るため
vim.keymap.set("n", ";", ":", { desc = "Command mode" })

vim.keymap.set("n", "<Esc><Esc>", "<Cmd>nohlsearch<CR>", { desc = "Clear search highlight" })

vim.keymap.set("i", "<C-c>", "<Esc><Cmd>w<CR>", { desc = "Exit and save" })

vim.keymap.set("i", ",", ",<Space>", { desc = "Comma with space" })

-- 矢印キーまで手を動かさずに済むようにする
vim.keymap.set("i", "<C-k>", "<Up>", { desc = "Move up" })
vim.keymap.set("i", "<C-j>", "<Down>", { desc = "Move down" })
vim.keymap.set("i", "<C-l>", "<Right>", { desc = "Move right" })
vim.keymap.set("i", "<C-h>", "<Left>", { desc = "Move left" })

-- 補完メニュー表示中は候補選択、それ以外は履歴移動にする
vim.keymap.set("c", "<C-n>", function()
  return vim.fn.wildmenumode() == 1 and "<C-n>" or "<Down>"
end, { expr = true, desc = "Select next completion item" })

vim.keymap.set("c", "<C-p>", function()
  return vim.fn.wildmenumode() == 1 and "<C-p>" or "<Up>"
end, { expr = true, desc = "Select previous completion item" })

-- ========================================
-- バッファ操作
-- ========================================

vim.keymap.set("n", "<Tab>", "<Cmd>bnext<CR>", { desc = "Next buffer" })
vim.keymap.set("n", "<S-Tab>", "<Cmd>bprevious<CR>", { desc = "Previous buffer" })
vim.keymap.set("n", "<Leader>bn", "<Cmd>bnext<CR>", { desc = "Next buffer" })
vim.keymap.set("n", "<Leader>bp", "<Cmd>bprevious<CR>", { desc = "Previous buffer" })

vim.keymap.set("n", "<Leader>bd", "<Cmd>bdelete<CR>", { desc = "Delete buffer" })
vim.keymap.set("n", "<Leader>bx", "<Cmd>bdelete!<CR>", { desc = "Force delete buffer" })

vim.keymap.set("n", "<Leader>bo", function()
  local current = vim.api.nvim_get_current_buf()
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if buf ~= current and vim.api.nvim_buf_is_loaded(buf) and vim.bo[buf].buftype == "" then
      vim.api.nvim_buf_delete(buf, { force = true })
    end
  end
end, { desc = "Close other buffers" })

vim.keymap.set("n", "<Leader>q", function()
  local cur_win = vim.api.nvim_get_current_win()
  local cur_buf = vim.api.nvim_get_current_buf()
  if vim.bo[cur_buf].filetype == "help" then
    vim.cmd("q")
    return
  end
  local buf_count = 0
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(buf) and vim.bo[buf].buftype == "" then
      buf_count = buf_count + 1
    end
  end
  -- 最後のバッファを消すと空バッファが残るだけなので、Neovimごと終了する
  if buf_count <= 1 then
    vim.cmd("qa!")
    return
  end
  pcall(vim.cmd, "bd!")
  if vim.api.nvim_win_is_valid(cur_win) then
    pcall(vim.api.nvim_win_close, cur_win, true)
  end
end, { desc = "Quit current tab or window" })

-- ========================================
-- 検索(mini.pick / mini.extra)
-- ========================================

-- dotfilesでは隠しファイルやgitignore対象も開きたいため、Pick filesではなくrgを直接指定する
vim.keymap.set("n", "<Leader>ff", function()
  MiniPick.builtin.cli({
    command = { "rg", "--files", "--color=never", "--hidden", "--no-ignore-vcs", "--glob", "!**/.git/" },
  }, {
    source = {
      name = "Files (rg)",
      -- cliは既定でアイコンを出さないため、Pick filesと同じ表示にする
      show = function(buf_id, items, query)
        MiniPick.default_show(buf_id, items, query, { show_icons = true })
      end,
    },
  })
end, { desc = "Search Files" })
vim.keymap.set("n", "<Leader>fg", "<Cmd>Pick grep_live<CR>", { desc = "Search by Grep" })
vim.keymap.set("n", "<Leader>fb", "<Cmd>Pick buffers<CR>", { desc = "Find existing buffers" })
vim.keymap.set("n", "<Leader>f/", "<Cmd>Pick buf_lines scope='current'<CR>", { desc = "Fuzzy find in current buffer" })
vim.keymap.set("n", "<Leader>fd", "<Cmd>Pick diagnostic<CR>", { desc = "Search Diagnostics" })
vim.keymap.set("n", "<Leader>fr", "<Cmd>Pick registers<CR>", { desc = "Search Registers" })
vim.keymap.set("n", "<Leader>fh", "<Cmd>Pick oldfiles<CR>", { desc = "Recent Files" })

vim.keymap.set("n", "<Leader>fw", function()
  MiniFiles.open(vim.fn.expand("%:p:h"))
end, { desc = "File browser" })

-- :Pickは引数をexpandcmd()で展開するので'%'が現在のファイルになる
vim.keymap.set("n", "<Leader>gb", "<Cmd>Pick git_commits path='%'<CR>", { desc = "Git log (current file)" })
vim.keymap.set("n", "<Leader>gl", "<Cmd>Pick git_commits<CR>", { desc = "Git log (all commits)" })

vim.keymap.set("n", "<Leader>un", function()
  MiniNotify.show_history()
end, { desc = "Notification history" })

-- ========================================
-- LSP
-- ========================================

-- 組み込みのgr*はmini.operatorsのgrと重なるため、<Leader>lにまとめる
vim.keymap.set("n", "<Leader>ld", "<Cmd>Pick lsp scope='definition'<CR>", { desc = "Go to definition" })
vim.keymap.set("n", "<Leader>lr", "<Cmd>Pick lsp scope='references'<CR>", { desc = "References" })
vim.keymap.set("n", "<Leader>li", "<Cmd>Pick lsp scope='implementation'<CR>", { desc = "Implementation" })
vim.keymap.set("n", "<Leader>lt", "<Cmd>Pick lsp scope='type_definition'<CR>", { desc = "Type definition" })
vim.keymap.set("n", "<Leader>lo", "<Cmd>Pick lsp scope='document_symbol'<CR>", { desc = "Document Symbols" })
vim.keymap.set("n", "<Leader>lw", "<Cmd>Pick lsp scope='workspace_symbol'<CR>", { desc = "Workspace Symbols" })
vim.keymap.set("n", "<Leader>ln", vim.lsp.buf.rename, { desc = "Rename" })
vim.keymap.set({ "n", "x" }, "<Leader>la", vim.lsp.buf.code_action, { desc = "Code action" })
vim.keymap.set("n", "<Leader>lf", vim.lsp.buf.format, { desc = "Format" })
vim.keymap.set("n", "<Leader>lh", function()
  vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = 0 }), { bufnr = 0 })
end, { desc = "Toggle inlay hints" })

-- ========================================
-- ヤンク履歴(yanky.nvim)
-- ========================================

vim.keymap.set({ "n", "x" }, "y", "<Plug>(YankyYank)")
vim.keymap.set({ "n", "x" }, "p", "<Plug>(YankyPutAfter)")
vim.keymap.set({ "n", "x" }, "P", "<Plug>(YankyPutBefore)")
-- vim.ui.selectはmini.pickに差し替わっているので、履歴もmini.pickで選べる
vim.keymap.set("n", "<Leader>p", "<Cmd>YankyRingHistory<CR>", { desc = "Yank History" })

-- ========================================
-- 日本語の文節単位移動(budouxify.nvim)
-- ========================================

-- find_*は移動先を返すだけなので、カーソルは自分で動かす
local function budoux_jump(find, head)
  return function()
    local pos = require("budouxify.motion")[find]({ head = head })
    if pos then
      vim.api.nvim_win_set_cursor(0, { pos.row, pos.col })
    end
  end
end

vim.keymap.set({ "n", "x" }, "W", budoux_jump("find_forward", true), { desc = "BudouX: Next word head" })
vim.keymap.set({ "n", "x" }, "E", budoux_jump("find_forward", false), { desc = "BudouX: Next word end" })
vim.keymap.set({ "n", "x" }, "B", budoux_jump("find_backward", true), { desc = "BudouX: Previous word head" })

-- ========================================
-- ファイラー(yazi)
-- ========================================

-- yaziで選んだファイルをこのNeovimで開くため、選択結果を--chooser-fileで受け取る
vim.keymap.set("n", "<Leader>yf", function()
  local dir = vim.fn.expand("%:p:h")
  local chooser = vim.fn.tempname()
  local width = math.floor(vim.o.columns * 0.8)
  local height = math.floor(vim.o.lines * 0.8)
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = width,
    height = height,
    row = math.floor((vim.o.lines - height) / 2),
    col = math.floor((vim.o.columns - width) / 2),
    style = "minimal",
    border = "rounded",
  })
  vim.fn.jobstart({ "yazi", "--chooser-file", chooser, dir }, {
    term = true,
    on_exit = function()
      -- バッファを消せばそれを表示するフロートも閉じるため、ウィンドウは別に閉じない
      vim.api.nvim_buf_delete(buf, { force = true })
      -- ファイルを選ばずに終了するとchooserは作られない
      if vim.fn.filereadable(chooser) == 0 then
        return
      end
      for _, file in ipairs(vim.fn.readfile(chooser)) do
        vim.cmd.edit(vim.fn.fnameescape(file))
      end
      vim.fn.delete(chooser)
    end,
  })
  vim.cmd.startinsert()
end, { desc = "Yazi file manager", silent = true })

-- ========================================
-- フローティングターミナル(vim-floaterm)
-- ========================================

vim.keymap.set("n", "<Leader>tt", "<Cmd>FloatermToggle<CR>", { silent = true, desc = "Toggle Floaterm" })
vim.keymap.set("n", "<Leader>tc", "<Cmd>FloatermNew<CR>", { silent = true, desc = "Create Floaterm" })
vim.keymap.set("n", "<Leader>tp", "<Cmd>FloatermPrev<CR>", { silent = true, desc = "Prev Floaterm" })
vim.keymap.set("n", "<Leader>tn", "<Cmd>FloatermNext<CR>", { silent = true, desc = "Next Floaterm" })

-- ========================================
-- チートシート
-- ========================================

-- 元ファイルを誤って書き換えないよう、内容を読み込んだ使い捨てバッファで表示する
local function open_cheatsheet()
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.fn.readfile(vim.fn.stdpath("config") .. "/cheatsheet.md"))
  vim.bo[buf].modifiable = false
  vim.bo[buf].bufhidden = "wipe"
  vim.bo[buf].filetype = "markdown"
  local width = math.floor(vim.o.columns * 0.8)
  local height = math.floor(vim.o.lines * 0.8)
  vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = width,
    height = height,
    row = math.floor((vim.o.lines - height) / 2),
    col = math.floor((vim.o.columns - width) / 2),
    style = "minimal",
    border = "rounded",
    title = " Cheatsheet ",
    title_pos = "center",
  })
  vim.keymap.set("n", "q", "<Cmd>close<CR>", { buffer = buf, nowait = true, desc = "Close cheatsheet" })
  vim.keymap.set("n", "<Esc>", "<Cmd>close<CR>", { buffer = buf, nowait = true, desc = "Close cheatsheet" })
end

vim.keymap.set("n", "<Leader>?", open_cheatsheet, { desc = "Cheatsheet" })

-- ========================================
-- ユーザーコマンド
-- ========================================

-- 再実行時に既存定義があってもエラーにしないためforceを付ける
vim.api.nvim_create_user_command("InitLua", function()
  vim.cmd.edit(vim.fn.stdpath("config") .. "/init.lua")
end, { force = true, desc = "Edit init.lua" })
