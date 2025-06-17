pcall(function() vim.loader.enable() end)

_G.Config = {
  path_package = vim.fn.stdpath("data") .. "/site/",
  path_source = vim.fn.stdpath("config") .. "/lua/",
}

vim.api.nvim_create_user_command(
    "InitLua",
    function()
        vim.cmd.edit(vim.fn.stdpath("config") .. "/init.lua")
    end,
    {}
)

local augroup = vim.api.nvim_create_augroup("init.lua", {})
local function create_autocmd(event, opts)
  vim.api.nvim_create_autocmd(event, vim.tbl_extend("force", {
    group = augroup,
  }, opts))
end

local mini_path = Config.path_package .. "pack/deps/start/mini.nvim"
if not vim.loop.fs_stat(mini_path) then
  vim.cmd([[echo "Installing 'mini.nvim'" | redraw]])
  local clone_cmd = { "git", "clone", "--filter=blob:none", "https://github.com/echasnovski/mini.nvim", mini_path }
  vim.fn.system(clone_cmd)
end
require("mini.deps").setup({ path = { package = Config.path_package } })

local add, now, later = MiniDeps.add, MiniDeps.now, MiniDeps.later
local source = function(path) dofile(Config.path_source .. path) end

now(function()
  source("config/options.lua")
  source("config/keymaps.lua")
  require("mini.basics").setup({
    options = { extra_ui = true },
    mappings = { option_toggle_prefix = "m" },
  })
  require("mini.icons").setup()
  require("mini.starter").setup()
  require("mini.misc").setup()
  MiniMisc.setup_restore_cursor()
  require("mini.statusline").setup()
  vim.opt.laststatus = 3
  vim.opt.cmdheight = 0
  vim.api.nvim_create_autocmd({ "RecordingEnter", "CmdlineEnter" }, {
    pattern = "*",
    callback = function()
      vim.opt.cmdheight = 1
    end,
  })
  vim.api.nvim_create_autocmd("RecordingLeave", {
    pattern = "*",
    callback = function()
      vim.opt.cmdheight = 0
    end,
  })
  vim.api.nvim_create_autocmd("CmdlineLeave", {
    pattern = "*",
    callback = function()
      if vim.fn.reg_recording() == "" then
        vim.opt.cmdheight = 0
      end
    end,
  })
  require("mini.notify").setup()
  vim.notify = require("mini.notify").make_notify({
    ERROR = { duration = 20000 },
    WARN = { duration = 20000 }
  })
end)

later(function()
  source("plugins/treesitter.lua")
  source("plugins/telescope.lua")

  add("https://github.com/vim-jp/vimdoc-ja")
  vim.opt.helplang:prepend("ja")

  require("mini.tabline").setup()
  require("mini.bufremove").setup()
  vim.api.nvim_create_user_command(
    "BufDelete",
    function()
      MiniBufremove.delete()
    end,
    {}
  )
  require("mini.comment").setup({
    options = {
      ignore_blank_line = true,
      start_of_line = true,
    },
    mappings = {
      comment = "<Leader>/",
      comment_line = "<Leader>/",
      comment_visual = "<Leader>/",
    }
  })
  require("mini.cursorword").setup({ draw = { delay = 200 } })
  require("mini.indentscope").setup()
  require("mini.trailspace").setup()
  vim.api.nvim_create_autocmd({ "BufWritePre" }, {
    callback = function()
      MiniTrailspace.trim()
      MiniTrailspace.trim_last_lines()
    end,
  })
  require("mini.pairs").setup()
  require("mini.surround").setup({ draw = { delay = 30 } })
  require("mini.splitjoin").setup({ mappings = { toggle = "<Leader>s" } })
  require("mini.move").setup()
  require("mini.align").setup()
  require("mini.diff").setup()

  -- colorscheme
  source("theme/rose-pine.lua")
end)
