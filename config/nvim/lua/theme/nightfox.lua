local add = MiniDeps.add
add({ source = "EdenEast/nightfox.nvim" })

require('nightfox').setup({
    options = {
        compile_path = vim.fn.stdpath("cache") .. "/nightfox",
        compile_file_suffix = "_compiled",
        transparent = false,
        terminal_colors = true,
        dim_inactive = false,
        module_default = true,
        styles = {
            comments = "NONE",
            conditionals = "NONE",
            constants = "NONE",
            functions = "NONE",
            keywords = "NONE",
            numbers = "NONE",
            operators = "NONE",
            strings = "NONE",
            types = "NONE",
            variables = "NONE",
        },
        inverse = {
            match_paren = false,
            visual = false,
            search = false,
        },
    },
    palettes = {},
    specs = {},
    groups = {},
})

vim.cmd.colorscheme("nightfox")
