local add = MiniDeps.add
add({ source = "rebelot/kanagawa.nvim" })

require('kanagawa').setup({
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
            -- IME変換時のハイライト - 文字を黒に
            CursorIM = { fg = "#000000", bg = theme.syn.fun, bold = true },
            -- TermCursor系もIMEに影響する場合がある
            TermCursor = { fg = "#000000", bg = theme.syn.fun },
            TermCursorNC = { fg = "#000000", bg = theme.ui.bg_p2 },
        }
    end,
    theme = "wave",
    background = {
        dark = "wave",
        light = "lotus"
    },
})

vim.cmd.colorscheme("kanagawa")
