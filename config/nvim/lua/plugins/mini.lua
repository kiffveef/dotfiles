-- lua/plugins/mini.lua: mini.nvim系プラグインの一括設定

-- 基本セットアップ
require("mini.basics").setup({
  options = { extra_ui = true },
  mappings = {},
})
require("mini.icons").setup()
require("mini.starter").setup()
require("mini.misc")
require("mini.statusline").setup()
require('mini.keymap')

-- タブライン・バッファ操作
require("mini.tabline").setup()
require("mini.bufremove").setup()
vim.api.nvim_create_user_command(
  "BufDelete",
  function()
    MiniBufremove.delete()
  end,
  {}
)

-- コメント
require("mini.comment").setup({
  options = {
    ignore_blank_line = true,
    start_of_line = true,
  },
  mappings = {
    comment = "<C-_>",
    comment_line = "<C-_>",
    comment_visual = "<C-_>",
  }
})

-- カーソルワード・インデント・トレイルスペース
require("mini.cursorword").setup({ delay = 300 })
require("mini.indentscope").setup({ draw = { delay = 100 } })
require("mini.trailspace").setup()
vim.api.nvim_create_autocmd({ "BufWritePre" }, {
  callback = function()
    if vim.bo.filetype == "markdown" then return end
    MiniTrailspace.trim()
    MiniTrailspace.trim_last_lines()
  end,
})

-- 括弧・サラウンド・分割結合・移動・整列・diff
require("mini.pairs").setup()
require("mini.surround").setup({
  custom_surroundings = {
    -- スペース付き括弧 (元のキー)
    ['('] = { output = { left = '( ', right = ' )' } },
    ['['] = { output = { left = '[ ', right = ' ]' } },
    ['{'] = { output = { left = '{ ', right = ' }' } },
    -- スペースなし括弧 (閉じ括弧で指定)
    [')'] = { output = { left = '(', right = ')' } },
    [']'] = { output = { left = '[', right = ']' } },
    ['}'] = { output = { left = '{', right = '}' } },

    -- 40%キーボード向け英字キー
    -- 丸括弧: b=(), B=( )
    ['b'] = { output = { left = '(', right = ')' } },
    ['B'] = { output = { left = '( ', right = ' )' } },
    -- 角括弧: r=[], R=[ ]
    ['r'] = { output = { left = '[', right = ']' } },
    ['R'] = { output = { left = '[ ', right = ' ]' } },
    -- 波括弧: c={}, C={ }
    ['c'] = { output = { left = '{', right = '}' } },
    ['C'] = { output = { left = '{ ', right = ' }' } },

    -- 日本語括弧
    ['j'] = { output = { left = '「', right = '」' } },
    ['k'] = { output = { left = '『', right = '』' } },
  },
})
require("mini.splitjoin").setup({ mappings = { toggle = "<Leader>s" } })
require("mini.move").setup()
require("mini.align").setup()
require("mini.diff").setup()

-- mini.clue設定 (キーヒント表示)
require("mini.clue").setup({
  triggers = {
    -- Leaderトリガー
    { mode = 'n', keys = '<Leader>' },
    { mode = 'x', keys = '<Leader>' },

    -- Surround
    { mode = 'n', keys = 's' },
    { mode = 'x', keys = 's' },

    -- 組み込み補完
    { mode = 'i', keys = '<C-x>' },

    -- gキー
    { mode = 'n', keys = 'g' },
    { mode = 'x', keys = 'g' },

    -- マーク
    { mode = 'n', keys = "'" },
    { mode = 'n', keys = '`' },
    { mode = 'x', keys = "'" },
    { mode = 'x', keys = '`' },

    -- レジスタ
    { mode = 'n', keys = '"' },
    { mode = 'x', keys = '"' },
    { mode = 'i', keys = '<C-r>' },
    { mode = 'c', keys = '<C-r>' },

    -- ウィンドウコマンド
    { mode = 'n', keys = '<C-w>' },

    -- zキー
    { mode = 'n', keys = 'z' },
    { mode = 'x', keys = 'z' },

    -- [と]キー (ナビゲーション)
    { mode = 'n', keys = '[' },
    { mode = 'n', keys = ']' },
  },

  clues = {
    -- Leaderグループの説明
    { mode = 'n', keys = '<Leader>b', desc = '+Buffer' },
    { mode = 'n', keys = '<Leader>f', desc = '+Find' },
    { mode = 'n', keys = '<Leader>g', desc = '+Git' },
    { mode = 'n', keys = '<Leader>l', desc = '+LSP' },
    { mode = 'n', keys = '<Leader>m', desc = '+Memo' },
    { mode = 'n', keys = '<Leader>t', desc = '+Terminal' },
    { mode = 'n', keys = '<Leader>u', desc = '+UI' },
    { mode = 'n', keys = '<Leader>y', desc = '+Yazi' },

    -- Surround
    { mode = 'n', keys = 'sa', desc = 'Add surrounding' },
    { mode = 'n', keys = 'sd', desc = 'Delete surrounding' },
    { mode = 'n', keys = 'sr', desc = 'Replace surrounding' },
    { mode = 'n', keys = 'sf', desc = 'Find surrounding (right)' },
    { mode = 'n', keys = 'sF', desc = 'Find surrounding (left)' },
    { mode = 'n', keys = 'sh', desc = 'Highlight surrounding' },
    { mode = 'n', keys = 'sn', desc = 'Update n_lines' },
    { mode = 'x', keys = 'sa', desc = 'Add surrounding' },
    -- 40%向け英字キー (推奨)
    { mode = 'n', keys = 'sab', desc = '()' },
    { mode = 'n', keys = 'saB', desc = '( )' },
    { mode = 'n', keys = 'sar', desc = '[]' },
    { mode = 'n', keys = 'saR', desc = '[ ]' },
    { mode = 'n', keys = 'sac', desc = '{}' },
    { mode = 'n', keys = 'saC', desc = '{ }' },
    { mode = 'n', keys = 'saj', desc = '「」' },
    { mode = 'n', keys = 'sak', desc = '『』' },

    -- 組み込みヘルパー
    require("mini.clue").gen_clues.builtin_completion(),
    require("mini.clue").gen_clues.g(),
    require("mini.clue").gen_clues.marks(),
    require("mini.clue").gen_clues.registers(),
    require("mini.clue").gen_clues.windows(),
    require("mini.clue").gen_clues.z(),
  },

  window = {
    delay = 0,
    config = {
      width = 'auto',
      border = 'rounded',
    },
  },
})
