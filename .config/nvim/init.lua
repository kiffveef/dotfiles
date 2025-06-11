pcall(function() vim.loader.enable() end)

_G.Config = {
  path_package = vim.fn.stdpath("data") .. "/site/",
  path_source = vim.fn.stdpath("config") .. "/lua/",
}

vim.api.nvim_create_user_command(
    'InitLua',
    function()
        vim.cmd.edit(vim.fn.stdpath("config") .. "/init.lua")
    end,
    {}
)

local augroup = vim.api.nvim_create_augroup('init.lua', {})
local function create_autocmd(event, opts)
  vim.api.nvim_create_autocmd(event, vim.tbl_extend('force', {
    group = augroup,
  }, opts))
end

local mini_path = Config.path_package .. "pack/deps/start/mini.nvim"
if not vim.loop.fs_stat(mini_path) then
  vim.cmd([[echo "Installing 'mini.nvim'" | redraw]])
  local clone_cmd = { "git", "clone", "--filter=blob:none", "https://github.com/echasnovski/mini.nvim", mini_path }
  vim.fn.system(clone_cmd)
end
require('mini.deps').setup({ path = { package = Config.path_package } })

local add, now, later = MiniDeps.add, MiniDeps.now, MiniDeps.later
local source = function(path) dofile(Config.path_source .. path) end

now(function() source("config/options.lua") end)
now(function() source("config/keymaps.lua") end)

now(function() require('mini.basics').setup({
  options = {
    extra_ui = true,
  },
  mappings = {
    option_toggle_prefix = "m",
  },
}) end)
now(function() require('mini.icons').setup() end)
now(function() require("mini.starter").setup() end)
now(function()
  require('mini.statusline').setup()
  vim.opt.laststatus = 3
  vim.opt.cmdheight = 0
  create_autocmd({ 'RecordingEnter', 'CmdlineEnter' }, {
    pattern = '*',
    callback = function()
      vim.opt.cmdheight = 1
    end,
  })
  create_autocmd('RecordingLeave', {
    pattern = '*',
    callback = function()
      vim.opt.cmdheight = 0
    end,
  })
  create_autocmd('CmdlineLeave', {
    pattern = '*',
    callback = function()
      if vim.fn.reg_recording() == '' then
        vim.opt.cmdheight = 0
      end
    end,
  })
end)

later(function()
  add("https://github.com/vim-jp/vimdoc-ja")
  vim.opt.helplang:prepend('ja')
end)
later(function() require('mini.tabline').setup() end)
later(function()
  require('mini.bufremove').setup()

  vim.api.nvim_create_user_command(
    'Bufdelete',
    function()
      MiniBufremove.delete()
    end,
    { desc = 'Remove buffer' }
  )
end)
later(function() require("mini.cursorword").setup() end)
later(function() require("mini.indentscope").setup() end)
later(function()
  require("mini.trailspace").setup()
  vim.api.nvim_create_user_command(
    "Trim",
    function()
      MiniTailspace.trim()
      MiniTailspace.trim_last_line()
    end,
    { desc = "Trim trailing whitespace and last line" }
  )
end)
later(function() require("mini.pairs").setup() end)
later(function()
  require("mini.surround").setup({
    draw = {
      delay = 30,
    }
  })
end)
later(function()
  local gen_ai_spec = require('mini.extra').gen_ai_spec
  require('mini.ai').setup({
    custom_textobjects = {
      B = gen_ai_spec.buffer(),
      D = gen_ai_spec.diagnostic(),
      I = gen_ai_spec.indent(),
      L = gen_ai_spec.line(),
      N = gen_ai_spec.number(),
      J = { { '()%d%d%d%d%-%d%d%-%d%d()', '()%d%d%d%d%/%d%d%/%d%d()' } }
    },
  })
end)
later(function()
  require('mini.splitjoin').setup({
    mappings = {
      toggle = 'gS',
      split = 'ss',
      join = 'sj',
    },
  })
end)
later(function() require('mini.move').setup() end)
