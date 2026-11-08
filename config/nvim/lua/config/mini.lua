-- ========================================
-- mini.nvimモジュール設定
-- ========================================

local now, later = MiniDeps.now, MiniDeps.later

-- ========================================
-- 起動直後の画面に必要なもの(now)
-- ========================================

now(function()
  require("mini.basics").setup({
    options = { extra_ui = true },
  })
end)

now(function()
  require("mini.icons").setup()
end)

-- 起動中に出る通知も拾えるよう、他モジュールより先にvim.notifyを差し替える
now(function()
  require("mini.notify").setup()
end)

-- starterがセッション一覧を表示できるよう、starterより先に読み込む
now(function()
  require("mini.sessions").setup()
end)

now(function()
  require("mini.starter").setup()
end)

now(function()
  require("mini.statusline").setup()
end)

now(function()
  require("mini.tabline").setup()
end)

-- 引数で開いたファイルの読み込みより前にautocmdを登録しないとカーソル復元が効かない
now(function()
  require("mini.misc").setup()
  MiniMisc.setup_restore_cursor()
end)

-- CursorMovedでしか描画しないため、laterだと引数で開いたファイルはカーソルを動かすまで表示されない
now(function()
  require("mini.cursorword").setup({ delay = 300 })
end)

now(function()
  require("mini.indentscope").setup({ draw = { delay = 100 } })
end)

-- laterだと`nvim <dir>`の引数ディレクトリをnetrwが先に開いてしまうため
now(function()
  require("mini.files").setup()
end)

-- LSP補完関数はBufEnterで設定されるため、laterだと引数で開いたファイルでLSP補完が効かない
now(function()
  require("mini.completion").setup()
end)

now(function()
  -- ウィンドウ分割時もステータスラインを1本にまとめて画面を広く使う
  vim.o.laststatus = 3
  -- 普段はコマンドラインを隠し、入力中とマクロ記録中だけ表示する
  vim.o.cmdheight = 0

  local group = vim.api.nvim_create_augroup("config_cmdheight", { clear = true })
  vim.api.nvim_create_autocmd({ "RecordingEnter", "CmdlineEnter" }, {
    group = group,
    callback = function()
      vim.o.cmdheight = 1
    end,
  })
  vim.api.nvim_create_autocmd("RecordingLeave", {
    group = group,
    callback = function()
      vim.o.cmdheight = 0
    end,
  })
  vim.api.nvim_create_autocmd("CmdlineLeave", {
    group = group,
    callback = function()
      -- マクロ記録中にコマンドラインを抜けても記録表示を消さない
      if vim.fn.reg_recording() == "" then
        vim.o.cmdheight = 0
      end
    end,
  })
end)

-- ========================================
-- 編集・表示補助(later)
-- ========================================

later(function()
  require("mini.bufremove").setup()
  -- :bdeleteと違いウィンドウレイアウトを崩さずにバッファを消すため
  vim.api.nvim_create_user_command("BufDelete", function()
    MiniBufremove.delete()
  end, {})
end)

later(function()
  require("mini.comment").setup({
    options = {
      ignore_blank_line = true,
      start_of_line = true,
    },
    -- 端末では<C-/>が<C-_>として届くため
    mappings = {
      comment = "<C-_>",
      comment_line = "<C-_>",
      comment_visual = "<C-_>",
    },
  })
end)

later(function()
  require("mini.trailspace").setup()
  vim.api.nvim_create_autocmd("BufWritePre", {
    group = vim.api.nvim_create_augroup("config_trailspace", { clear = true }),
    callback = function(args)
      -- 行末スペース2つが改行の意味を持つため
      if vim.bo[args.buf].filetype == "markdown" then
        return
      end
      -- 変更不可バッファで削除するとE21になるため
      if not vim.bo[args.buf].modifiable then
        return
      end
      MiniTrailspace.trim()
      MiniTrailspace.trim_last_lines()
    end,
  })
end)

-- mini.pairsが作る<CR>/<BS>を補完メニュー対応版で上書きするため、setup直後に続けて定義する
later(function()
  require("mini.pairs").setup()
  local map_multistep = require("mini.keymap").map_multistep
  map_multistep("i", "<Tab>", { "pmenu_next" })
  map_multistep("i", "<S-Tab>", { "pmenu_prev" })
  map_multistep("i", "<CR>", { "pmenu_accept", "minipairs_cr" })
  map_multistep("i", "<BS>", { "minipairs_bs" })
end)

-- スニペット集は入れず、LSP補完のスニペット候補を展開するためだけに使う
later(function()
  require("mini.snippets").setup({
    mappings = {
      -- 展開するスニペットがなく、既定の<C-j>はinsertモードのカーソル下移動を上書きしてしまうため
      expand = "",
    },
  })

  -- セッション中は<C-l>/<C-h>/<C-c>がジャンプ用に置き換わるため、ノーマルモードに戻ったら残さず終わらせる
  local group = vim.api.nvim_create_augroup("config_snippets", { clear = true })
  local make_stop = function()
    vim.api.nvim_create_autocmd("ModeChanged", {
      group = group,
      pattern = "*:n",
      once = true,
      callback = function()
        while MiniSnippets.session.get() do
          MiniSnippets.session.stop()
        end
      end,
    })
  end
  vim.api.nvim_create_autocmd("User", {
    group = group,
    pattern = "MiniSnippetsSessionStart",
    callback = make_stop,
  })
end)

-- 通常のinsertマッピングと違いjの入力がtimeoutlenを待たない
-- map_comboは呼ぶたびにハンドラが増えるため、保存時に再実行されるkeymaps.luaではなくここに置く
later(function()
  local map_combo = require("mini.keymap").map_combo
  map_combo("i", "jk", "<BS><BS><Esc>")
  map_combo("i", "jj", "<BS><BS><Esc>")
  map_combo("i", "kj", "<BS><BS><Esc>")
end)

later(function()
  require("mini.surround").setup({
    custom_surroundings = {
      -- 開き括弧はスペース付き
      ["("] = { output = { left = "( ", right = " )" } },
      ["["] = { output = { left = "[ ", right = " ]" } },
      ["{"] = { output = { left = "{ ", right = " }" } },
      -- 閉じ括弧はスペースなし
      [")"] = { output = { left = "(", right = ")" } },
      ["]"] = { output = { left = "[", right = "]" } },
      ["}"] = { output = { left = "{", right = "}" } },

      -- 40%キーボードでは記号入力にレイヤー切替が要るため英字キーでも指定できるようにする
      -- 丸括弧: b=(), B=( )
      ["b"] = { output = { left = "(", right = ")" } },
      ["B"] = { output = { left = "( ", right = " )" } },
      -- 角括弧: r=[], R=[ ]
      ["r"] = { output = { left = "[", right = "]" } },
      ["R"] = { output = { left = "[ ", right = " ]" } },
      -- 波括弧: c={}, C={ }
      ["c"] = { output = { left = "{", right = "}" } },
      ["C"] = { output = { left = "{ ", right = " }" } },

      -- 日本語括弧
      ["j"] = { output = { left = "「", right = "」" } },
      ["k"] = { output = { left = "『", right = "』" } },
    },
  })
end)

later(function()
  require("mini.splitjoin").setup({ mappings = { toggle = "<Leader>s" } })
end)

later(function()
  require("mini.move").setup()
end)

later(function()
  require("mini.align").setup()
end)

later(function()
  -- 変更が1箇所でも]h/[hで必ず飛べるよう末尾で折り返す
  require("mini.diff").setup({ options = { wrap_goto = true } })
end)

later(function()
  require("mini.git").setup()
end)

later(function()
  local hipatterns = require("mini.hipatterns")
  hipatterns.setup({
    highlighters = {
      fixme = { pattern = "FIXME", group = "MiniHipatternsFixme" },
      hack = { pattern = "HACK", group = "MiniHipatternsHack" },
      todo = { pattern = "TODO", group = "MiniHipatternsTodo" },
      note = { pattern = "NOTE", group = "MiniHipatternsNote" },
      hex_color = hipatterns.gen_highlighter.hex_color(),
    },
  })
end)

later(function()
  local ai = require("mini.ai")
  local spec_treesitter = ai.gen_spec.treesitter
  ai.setup({
    custom_textobjects = {
      f = spec_treesitter({ a = "@function.outer", i = "@function.inner" }),
      c = spec_treesitter({ a = "@class.outer", i = "@class.inner" }),
      -- fを関数定義に使うため、組み込みの関数呼び出しをFへ移す
      F = ai.gen_spec.function_call(),
    },
  })
end)

later(function()
  require("mini.bracketed").setup()
end)

later(function()
  require("mini.operators").setup()
end)

later(function()
  require("mini.jump2d").setup()
end)

-- setupでvim.ui.selectもmini.pickに差し替わる
later(function()
  require("mini.pick").setup()
end)

later(function()
  require("mini.extra").setup()
end)

-- ========================================
-- キーヒント(mini.clue)
-- ========================================

later(function()
  local miniclue = require("mini.clue")
  miniclue.setup({
    triggers = {
      -- Leaderトリガー
      { mode = "n", keys = "<Leader>" },
      { mode = "x", keys = "<Leader>" },

      -- Surround
      { mode = "n", keys = "s" },
      { mode = "x", keys = "s" },

      -- 組み込み補完
      { mode = "i", keys = "<C-x>" },

      -- gキー
      { mode = "n", keys = "g" },
      { mode = "x", keys = "g" },

      -- マーク
      { mode = "n", keys = "'" },
      { mode = "n", keys = "`" },
      { mode = "x", keys = "'" },
      { mode = "x", keys = "`" },

      -- レジスタ
      { mode = "n", keys = '"' },
      { mode = "x", keys = '"' },
      { mode = "i", keys = "<C-r>" },
      { mode = "c", keys = "<C-r>" },

      -- ウィンドウコマンド
      { mode = "n", keys = "<C-w>" },

      -- zキー
      { mode = "n", keys = "z" },
      { mode = "x", keys = "z" },

      -- [と]キー(ナビゲーション)
      { mode = "n", keys = "[" },
      { mode = "n", keys = "]" },
    },

    clues = {
      -- Leaderグループの説明
      { mode = "n", keys = "<Leader>b", desc = "+Buffer" },
      { mode = "n", keys = "<Leader>f", desc = "+Find" },
      { mode = "n", keys = "<Leader>g", desc = "+Git" },
      { mode = "n", keys = "<Leader>l", desc = "+LSP" },
      { mode = "n", keys = "<Leader>n", desc = "+Novel" },
      { mode = "n", keys = "<Leader>t", desc = "+Terminal" },
      { mode = "n", keys = "<Leader>u", desc = "+UI" },
      { mode = "n", keys = "<Leader>y", desc = "+Yazi" },

      -- Surround
      { mode = "n", keys = "sa", desc = "Add surrounding" },
      { mode = "n", keys = "sd", desc = "Delete surrounding" },
      { mode = "n", keys = "sr", desc = "Replace surrounding" },
      { mode = "n", keys = "sf", desc = "Find surrounding (right)" },
      { mode = "n", keys = "sF", desc = "Find surrounding (left)" },
      { mode = "n", keys = "sh", desc = "Highlight surrounding" },
      { mode = "x", keys = "sa", desc = "Add surrounding" },
      -- 40%向け英字キー(推奨)
      { mode = "n", keys = "sab", desc = "()" },
      { mode = "n", keys = "saB", desc = "( )" },
      { mode = "n", keys = "sar", desc = "[]" },
      { mode = "n", keys = "saR", desc = "[ ]" },
      { mode = "n", keys = "sac", desc = "{}" },
      { mode = "n", keys = "saC", desc = "{ }" },
      { mode = "n", keys = "saj", desc = "「」" },
      { mode = "n", keys = "sak", desc = "『』" },

      -- 組み込みヘルパー
      miniclue.gen_clues.builtin_completion(),
      miniclue.gen_clues.g(),
      miniclue.gen_clues.marks(),
      miniclue.gen_clues.registers(),
      miniclue.gen_clues.windows(),
      miniclue.gen_clues.z(),
    },

    window = {
      delay = 0,
      config = {
        width = "auto",
        border = "rounded",
      },
    },
  })
end)
