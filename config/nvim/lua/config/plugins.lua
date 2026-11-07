-- ========================================
-- mini.nvim以外のプラグイン設定
-- ========================================

local add, now, later = MiniDeps.add, MiniDeps.now, MiniDeps.later

-- ========================================
-- カラースキーム
-- ========================================

-- mini.*のUIモジュールより先に適用し、それらのハイライトをkanagawaの配色に合わせる
now(function()
  add({ source = "rebelot/kanagawa.nvim" })

  require("kanagawa").setup({
    compile = false,
    undercurl = true,
    commentStyle = {},
    functionStyle = {},
    keywordStyle = {},
    statementStyle = { bold = true },
    typeStyle = {},
    transparent = false,
    dimInactive = false,
    terminalColors = true,
    colors = {
      palette = {},
      theme = { wave = {}, lotus = {}, dragon = {}, all = {} },
    },
    overrides = function(colors)
      local theme = colors.theme
      return {
        Comment = { italic = false },
        Keyword = { italic = false },
        ["@keyword.return"] = { italic = false },
        -- IME変換中の文字が背景に埋もれないよう黒にする
        CursorIM = { fg = "#000000", bg = theme.syn.fun, bold = true },
        -- TermCursor系もIME変換中の表示に使われることがあるため
        TermCursor = { fg = "#000000", bg = theme.syn.fun },
        TermCursorNC = { fg = "#000000", bg = theme.ui.bg_p2 },
      }
    end,
    theme = "wave",
    background = {
      dark = "wave",
      light = "lotus",
    },
  })

  vim.cmd.colorscheme("kanagawa")
end)

-- ========================================
-- ライトテーマ(loglineプロジェクトのmarkdown)
-- ========================================

later(function()
  add({ source = "folke/tokyonight.nvim" })

  -- tokyonight.load()やcolorschemeはグローバルの配色を変えるため、色とグループだけ作って専用のnamespaceに入れる
  local opts = require("tokyonight.config").extend({ style = "day" })
  local colors = require("tokyonight.colors").setup(opts)
  local groups = require("tokyonight.groups").setup(colors, opts)
  local ns = vim.api.nvim_create_namespace("config_light_markdown")
  for group, hl in pairs(groups) do
    -- tokyonight側のtheme.luaと同じく、文字列はリンク先のグループ名として扱う
    hl = type(hl) == "string" and { link = hl } or hl
    vim.api.nvim_set_hl(ns, group, hl)
  end

  local function is_light_target(buf)
    return vim.bo[buf].filetype == "markdown" and vim.fs.root(buf, ".logline") ~= nil
  end

  local function apply(win)
    local buf = vim.api.nvim_win_get_buf(win)
    vim.api.nvim_win_set_hl_ns(win, is_light_target(buf) and ns or 0)
  end

  vim.api.nvim_create_autocmd({ "BufWinEnter", "FileType" }, {
    group = vim.api.nvim_create_augroup("config_light_markdown", { clear = true }),
    pattern = "*",
    callback = function()
      apply(vim.api.nvim_get_current_win())
    end,
  })

  -- laterより前に引数で開いたバッファは上のautocmdを通らないため、既存ウィンドウにも一度適用する
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    apply(win)
  end
end)

-- ========================================
-- treesitter
-- ========================================

local ts_languages = {
  "lua",
  "vim",
  "bash",
  "git_config",
  "git_rebase",
  "gitattributes",
  "gitcommit",
  "gitignore",
  "ruby",
  "javascript",
  "typescript",
  "dockerfile",
  "json",
  "yaml",
  "toml",
  "markdown",
  "markdown_inline",
  "html",
  "css",
  "tsx",
  "zsh",
  "make",
  "kdl",
  "rust",
}

-- laterだと引数で開いたファイルのFileTypeに間に合わず、最初の描画がハイライトなしになる
now(function()
  add({
    source = "nvim-treesitter/nvim-treesitter",
    checkout = "main",
    -- プラグイン更新後はパーサーも対応する版に揃える必要があるため
    hooks = {
      post_checkout = function()
        vim.cmd("TSUpdate")
      end,
    },
  })

  -- パーサー名とfiletype名は一致しないことがある(bash→shなど)ため、登録済みの対応表から引く
  local filetypes = {}
  for _, lang in ipairs(ts_languages) do
    vim.list_extend(filetypes, vim.treesitter.language.get_filetypes(lang))
  end

  vim.api.nvim_create_autocmd("FileType", {
    group = vim.api.nvim_create_augroup("config_treesitter", { clear = true }),
    pattern = filetypes,
    callback = function(args)
      local lang = vim.treesitter.language.get_lang(args.match)
      -- 新しい環境ではバックグラウンドのパーサーインストールが終わるまでstartがエラーになるため
      if not vim.treesitter.language.add(lang) then
        return
      end
      vim.treesitter.start(args.buf)
      -- indentsクエリのない言語(zsh, makeなど)では常に-1を返し、組み込みのインデントより悪くなるため
      if #vim.treesitter.query.get_files(lang, "indents") > 0 then
        vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
      end
    end,
  })
end)

-- インストール済みなら何もしない非同期処理なので、起動を待たせないようlaterで呼ぶ
later(function()
  require("nvim-treesitter").install(ts_languages)
end)

-- mini.aiのgen_spec.treesitterはtextobjectsクエリを参照するだけなので、setupは不要
later(function()
  add({ source = "nvim-treesitter/nvim-treesitter-textobjects", checkout = "main" })
end)

-- ========================================
-- LSP
-- ========================================

local lsp_servers = {
  "lua_ls",
  "ruby_lsp",
  "dockerls",
  "docker_compose_language_service",
  "ts_ls",
  "eslint",
  "cssls",
  "html",
  "rust_analyzer",
}

local ts_inlay_hints = {
  includeInlayParameterNameHints = "all",
  includeInlayFunctionParameterTypeHints = true,
  includeInlayVariableTypeHints = true,
}

-- laterだと引数で開いたファイルのFileTypeが先に発火し、そのバッファにクライアントが付かないため
now(function()
  add({ source = "neovim/nvim-lspconfig" })
  -- リポジトリがmason-orgへ移ったため。ディレクトリ名は同じなので既存のcloneがそのまま使われる
  add({ source = "mason-org/mason.nvim" })
  -- サーバー起動時にcmdが見つかるよう、masonのbinをPATHへ足す
  require("mason").setup()

  vim.lsp.config("*", { capabilities = require("mini.completion").get_lsp_capabilities() })

  vim.lsp.config("ts_ls", {
    settings = {
      typescript = { inlayHints = ts_inlay_hints },
      javascript = { inlayHints = ts_inlay_hints },
    },
  })

  -- on_attachは差し替えになるため、LspEslintFixAllを定義するlspconfig側のon_attachも呼ぶ
  local eslint_on_attach = vim.lsp.config.eslint.on_attach
  local eslint_group = vim.api.nvim_create_augroup("config_eslint_fix", { clear = true })
  vim.lsp.config("eslint", {
    on_attach = function(client, bufnr)
      eslint_on_attach(client, bufnr)
      -- :lsp restartなどで再アタッチされるたびに保存時の修正が重複して走らないようにする
      vim.api.nvim_clear_autocmds({ group = eslint_group, buffer = bufnr })
      vim.api.nvim_create_autocmd("BufWritePre", {
        group = eslint_group,
        buffer = bufnr,
        command = "LspEslintFixAll",
      })
    end,
  })

  vim.lsp.enable(lsp_servers)
end)

-- インストール確認はmasonのレジストリ読み込みが重いため、起動後に回す
later(function()
  add({ source = "mason-org/mason-lspconfig.nvim" })
  require("mason-lspconfig").setup({
    ensure_installed = lsp_servers,
    -- 有効化は上のvim.lsp.enableで済ませているため、二重に有効化しない
    automatic_enable = false,
  })
end)

-- ========================================
-- ヤンク履歴
-- ========================================

later(function()
  add({ source = "gbprod/yanky.nvim" })
  require("yanky").setup({
    highlight = {
      on_put = true,
      on_yank = true,
      timer = 200,
    },
    ring = {
      history_length = 100,
      storage = "shada",
      sync_with_numbered_registers = true,
    },
    picker = {
      select = { action = nil },
    },
    system_clipboard = {
      sync_with_clipboard = false,
      register_sync = false,
    },
  })
end)

-- ========================================
-- 日本語の文節単位移動(キーマップはkeymaps.lua)
-- ========================================

later(function()
  add({ source = "atusy/budouxify.nvim", depends = { "atusy/budoux.lua" } })
end)

-- ========================================
-- フローティングターミナル
-- ========================================

later(function()
  vim.g.floaterm_width = 0.8
  vim.g.floaterm_height = 0.8
  add({ source = "voldikss/vim-floaterm" })
end)
