if vim.fn.has("wsl")  == 1 then
  -- vim.cmd([[
  --   augroup myYank
  --     autocmd!
  --     autocmd TextYankPost * :call system('win32yank -i',  @")
  --   augroup END
  -- ]])
  vim.api.nvim_create_autocmd("TextYankPost", {
    group = vim.api.nvim_create_augroup("Yank", { clear = true }),
    callback = function()
      vim.fn.system("win32yank", vim.fn.getreg('"'))
    end
  })
  vim.g.clipboard = {
    name = "win32yank-wsl",
    copy = {
      ["+"] = "win32yank -i",
      ["*"] = "win32yank -i",
    },
    paste = {
      ["+"] = "win32yank -o --crlf",
      ["*"] = "win32yank -o --crlf",
    },
    cache_enabled = 0,
  }

  vim.cmd([[
    if executable('zenhan')
      augroup ime_changestate
        autocmd!
        autocmd InsertLeave * :call system('zenhan 0')
        autocmd CmdlineLeave * :call system('zenhan 0')
      augroup END
    endif
  ]])
end

if vim.fn.has("macunix") == 1 then
  vim.g.mapleader = "_"
end
