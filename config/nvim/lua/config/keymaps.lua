-- ========================================
-- キーマップ設定 (mini.clue統合版)
-- ========================================

-- ========================================
-- 基本キーマップ
-- ========================================

-- ; と : を入れ替え
vim.keymap.set("n", ";", ":", { desc = "Command mode" })

-- 検索ハイライトOFF
vim.keymap.set("n", "<Esc><Esc>", "<Cmd>nohlsearch<CR>", { desc = "Clear search highlight" })

-- インサートモード離脱
vim.keymap.set("i", "jk", "<Esc>", { desc = "Exit insert mode" })
vim.keymap.set("i", "jj", "<Esc>", { desc = "Exit insert mode" })
vim.keymap.set("i", "kj", "<Esc>", { desc = "Exit insert mode" })

-- <C-c> でインサートモードを抜けて保存
vim.keymap.set("i", "<C-c>", "<Esc><Cmd>w<CR>", { desc = "Exit and save" })

-- スペース挿入
vim.keymap.set("i", ",", ",<Space>", { desc = "Comma with space" })

-- インサートモード中のカーソル移動
vim.keymap.set("i", "<C-k>", "<Up>", { desc = "Move up" })
vim.keymap.set("i", "<C-j>", "<Down>", { desc = "Move down" })
vim.keymap.set("i", "<C-l>", "<Right>", { desc = "Move right" })
vim.keymap.set("i", "<C-h>", "<Left>", { desc = "Move left" })

-- コマンドライン補完
vim.keymap.set("c", "<C-n>", function()
  return vim.fn.wildmenumode() == 1 and "<C-n>" or "<Down>"
end, { expr = true, desc = "Select next completion item" })

vim.keymap.set("c", "<C-p>", function()
  return vim.fn.wildmenumode() == 1 and "<C-p>" or "<Up>"
end, { expr = true, desc = "Select previous completion item" })

-- ========================================
-- バッファ操作
-- ========================================

-- バッファ移動
vim.keymap.set("n", "<Tab>", function()
  if vim.bo.filetype == "logline-sidebar" then
    return
  end
  vim.cmd("bnext")
end, { desc = "Next buffer" })
vim.keymap.set("n", "<S-Tab>", "<Cmd>bprevious<CR>", { desc = "Previous buffer" })
vim.keymap.set("n", "<Leader>bn", "<Cmd>bnext<CR>", { desc = "Next buffer" })
vim.keymap.set("n", "<Leader>bp", "<Cmd>bprevious<CR>", { desc = "Previous buffer" })

-- バッファを閉じる（ウィンドウは維持）
vim.keymap.set("n", "<Leader>bd", "<Cmd>bdelete<CR>", { desc = "Delete buffer" })
vim.keymap.set("n", "<Leader>bx", "<Cmd>bdelete!<CR>", { desc = "Force delete buffer" })

-- 他のバッファをすべて閉じる
vim.keymap.set("n", "<Leader>bo", function()
  local current = vim.api.nvim_get_current_buf()
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if buf ~= current and vim.api.nvim_buf_is_loaded(buf) and vim.bo[buf].buftype == "" then
      vim.api.nvim_buf_delete(buf, { force = true })
    end
  end
end, { desc = "Close other buffers" })

-- バッファ/ウィンドウを閉じる
vim.keymap.set('n', '<Leader>q', function()
  local cur_win = vim.api.nvim_get_current_win()
  local cur_buf = vim.api.nvim_get_current_buf()
  if vim.bo[cur_buf].filetype == 'help' then
    vim.cmd('q')
    return
  end
  local buf_count = 0
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(buf) and vim.bo[buf].buftype == '' then
      buf_count = buf_count + 1
    end
  end
  if buf_count <= 1 then
    vim.cmd('qa!')
    return
  end
  pcall(vim.cmd, 'bd!')
  if vim.api.nvim_win_is_valid(cur_win) then
    pcall(vim.api.nvim_win_close, cur_win, true)
  end
end, { desc = "Quit current tab or window" })

-- ========================================
-- Telescope関連
-- ========================================

local has_telescope, builtin = pcall(require, "telescope.builtin")
local has_theme, telescope_theme = pcall(require, "plugins.telescope_theme")

if has_telescope then
  vim.keymap.set("n", "<Leader>ff", builtin.find_files, { desc = "Search Files" })
  vim.keymap.set("n", "<Leader>fg", builtin.live_grep, { desc = "Search by Grep" })
  vim.keymap.set("n", "<Leader>fb", builtin.buffers, { desc = "Find existing buffers" })
  vim.keymap.set("n", "<Leader>f/", builtin.current_buffer_fuzzy_find, { desc = "Fuzzy find in current buffer" })
  vim.keymap.set("n", "<Leader>fd", builtin.diagnostics, { desc = "Search Diagnostics" })
  vim.keymap.set("n", "<Leader>fr", builtin.registers, { desc = "Search Registers" })
  vim.keymap.set("n", "<Leader>fh", builtin.oldfiles, { desc = "Recent Files" })

  -- File browser
  vim.keymap.set("n", "<Leader>fw", function()
    local telescope_ex = require("telescope").extensions.file_browser
    telescope_ex.file_browser({
      path = "%:p:h",
      cwd = vim.fn.expand("%:p:h"),
    })
  end, { desc = "File browser" })

  -- Git
  if has_theme then
    vim.keymap.set("n", "<Leader>gb", function()
      builtin.git_bcommits(telescope_theme.get_theme_with_height(telescope_theme.git.height))
    end, { desc = "Git blame (file commits)" })

    vim.keymap.set("n", "<Leader>gl", function()
      builtin.git_commits(telescope_theme.get_theme_with_height(telescope_theme.git.height))
    end, { desc = "Git log (all commits)" })
  end
end

-- ========================================
-- LSP関連
-- ========================================

if has_telescope and has_theme then
  local ivy_theme = telescope_theme.themes and telescope_theme.get_theme_with_height(telescope_theme.height.height) or {}
  vim.keymap.set("n", "<Leader>lo", function()
    builtin.lsp_document_symbols(ivy_theme)
  end, { desc = "Document Symbols" })

  vim.keymap.set("n", "<Leader>lw", function()
    builtin.lsp_workspace_symbols(ivy_theme)
  end, { desc = "Workspace Symbols" })

  vim.keymap.set("n", "<Leader>ld", function()
    builtin.lsp_definitions(ivy_theme)
  end, { desc = "Go to definition" })
else
  vim.keymap.set("n", "<Leader>lo", vim.lsp.buf.document_symbol, { desc = "Document Symbols" })
  vim.keymap.set("n", "<Leader>lw", vim.lsp.buf.workspace_symbol, { desc = "Workspace Symbols" })
  vim.keymap.set("n", "<Leader>ld", vim.lsp.buf.definition, { desc = "Go to definition" })
end

-- ========================================
-- Yanky関連
-- ========================================

local has_yanky = pcall(require, "yanky")
if has_yanky then
  vim.keymap.set("n", "<Leader>p", function()
    require("telescope").extensions.yank_history.yank_history({})
  end, { desc = "Yank History" })

  vim.keymap.set({ "n", "x" }, "y", "<Plug>(YankyYank)")
  vim.keymap.set({ "n", "x" }, "p", "<Plug>(YankyPutAfter)")
  vim.keymap.set({ "n", "x" }, "P", "<Plug>(YankyPutBefore)")
end

-- ========================================
-- Yazi関連
-- ========================================

local has_yazi, yazi_module = pcall(require, "plugins.yazi")
if has_yazi and yazi_module.open_yazi then
  vim.keymap.set("n", "<Leader>yf", yazi_module.open_yazi, { desc = "Yazi file manager", silent = true })
end

-- ========================================
-- Floaterm関連
-- ========================================

vim.keymap.set("n", "<Leader>tt", "<Cmd>FloatermToggle<CR>", { silent = true, desc = "Toggle Floaterm" })
vim.keymap.set("n", "<Leader>tc", "<Cmd>FloatermNew<CR>", { silent = true, desc = "Create Floaterm" })
vim.keymap.set("n", "<Leader>tp", "<Cmd>FloatermPrev<CR>", { silent = true, desc = "Prev Floaterm" })
vim.keymap.set("n", "<Leader>tn", "<Cmd>FloatermNext<CR>", { silent = true, desc = "Next Floaterm" })

-- ========================================
-- Memo関連
-- ========================================

vim.keymap.set("n", "<Leader>mn", "<Cmd>MemoNew<CR>", { silent = true, desc = "New memo" })
vim.keymap.set("n", "<Leader>ml", "<Cmd>MemoList<CR>", { silent = true, desc = "Memo list" })
vim.keymap.set("n", "<Leader>mg", "<Cmd>MemoGrep<CR>", { silent = true, desc = "Memo grep" })

-- ========================================
-- Notify関連
-- ========================================

vim.keymap.set("n", "<Leader>un", function()
  require("telescope").extensions.notify.notify(
    require("telescope.themes").get_ivy({
      layout_config = { height = 0.4 },
      attach_mappings = function(_, map)
        local actions = require("telescope.actions")
        -- Enterキーで選択してもポップアップを再表示しない(デフォルト動作を無効化)
        map("i", "<CR>", actions.close)
        map("n", "<CR>", actions.close)
        -- Ctrl+yでクリップボードにコピー(ポップアップは開いたまま)
        map("i", "<C-y>", function()
          local entry = require("telescope.actions.state").get_selected_entry()
          if entry and entry.value then
            local msg = type(entry.value) == "table" and entry.value.message or tostring(entry.value)
            vim.fn.setreg("+", msg)
          end
        end)
        map("n", "<C-y>", function()
          local entry = require("telescope.actions.state").get_selected_entry()
          if entry and entry.value then
            local msg = type(entry.value) == "table" and entry.value.message or tostring(entry.value)
            vim.fn.setreg("+", msg)
          end
        end)
        return true
      end,
    })
  )
end, { desc = "Notification history" })
