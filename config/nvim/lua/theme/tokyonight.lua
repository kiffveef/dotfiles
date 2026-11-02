local add = MiniDeps.add
add({ source = "folke/tokyonight.nvim" })

require("tokyonight").setup({
    style = "storm",
    transparent = false,
    terminal_colors = true,
    styles = {
        comments = { italic = false },
        keywords = { italic = false },
        functions = {},
        variables = {},
        sidebars = "dark",
        floats = "dark",
    },
    day_brightness = 0.3,
    dim_inactive = false,
    lualine_bold = false,
    on_colors = function(colors)
    end,
    on_highlights = function(highlights, colors)
    end,
    cache = true,
})

vim.cmd.colorscheme("tokyonight")
