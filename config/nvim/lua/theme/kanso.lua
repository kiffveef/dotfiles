local add = MiniDeps.add
add({ source = "webhooked/kanso.nvim" })

require('kanso').setup({
    bold = true,
    italics = false,
    compile = false,
    undercurl = true,
    commentStyle = {},
    functionStyle = {},
    keywordStyle = {},
    statementStyle = {},
    typeStyle = {},
    transparent = false,
    dimInactive = false,
    terminalColors = true,
    colors = {
        palette = {},
        theme = { zen = {}, pearl = {}, ink = {}, all = {} },
    },
    overrides = function(colors)
        return {}
    end,
    theme = "ink",
    background = {
        dark = "ink",
        light = "pearl"
    },
})

vim.cmd.colorscheme("kanso")
