local add = MiniDeps.add

add("yukimura1227/vim-yazi")

vim.g.yazi_open_command = 'edit'

local function open_yazi()
  local laststatus = vim.opt.laststatus:get()
  local number = vim.opt.number:get()
  local empty_buf = nil
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(buf)
      and vim.bo[buf].buftype == ''
      and vim.bo[buf].filetype == ''
      and vim.bo[buf].modifiable
    then
      empty_buf = buf
      break
    end
  end
  if empty_buf then
    vim.cmd('buffer ' .. empty_buf)
  else
    vim.cmd('enew')
  end
  vim.cmd("terminal yazi")
  vim.opt_local.laststatus = 0
  vim.opt_local.number = false
  vim.api.nvim_create_autocmd("TermClose", {
    once = true,
    buffer = 0,
    callback = function()
      vim.opt.laststatus = laststatus
      vim.opt.number = number
      local term_buf = vim.api.nvim_get_current_buf()
      if vim.api.nvim_buf_is_valid(term_buf) and vim.bo[term_buf].buftype == 'terminal' then
        vim.cmd('bd!')
      end
      local win = vim.api.nvim_get_current_win()
      local cur_buf = vim.api.nvim_win_get_buf(win)
      if vim.bo[cur_buf].buftype == 'terminal' then
        vim.cmd('bprevious')
      end
    end,
  })
end

vim.api.nvim_create_autocmd("BufEnter", {
  callback = function()
    local cur_buf = vim.api.nvim_get_current_buf()
    if vim.bo[cur_buf].buftype == '' and vim.bo[cur_buf].filetype ~= '' then
      local cur_tab = vim.api.nvim_get_current_tabpage()
      for _, tab in ipairs(vim.api.nvim_list_tabpages()) do
        if tab ~= cur_tab then
          vim.api.nvim_set_current_tabpage(tab)
          vim.cmd('tabclose')
        end
      end
      vim.api.nvim_set_current_tabpage(cur_tab)
    end
  end,
})

-- キーマップはlua/config/keymaps.luaに統合されました

return { open_yazi = open_yazi }
