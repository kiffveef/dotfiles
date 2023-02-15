if vim.fn.has("wsl")  == 1 then
  vim.g.clipboard = {
    name = "clipboard-wsl",
    copy = {
      ["+"] = "gocopy",
      ["*"] = "gocopy",
    },
    paste = {
      ["+"] = "gopaste",
      ["*"] = "gopaste",
    },
    cache_enabled = 1,
  }

  vim.api.nvim_create_autocmd({ "InsertLeave", "CmdlineLeave" }, {
    pattern = "*",
    group = vim.api.nvim_create_augroup("ime_status_change", { clear = true }),
    callback = function()
      vim.fn.system("zenhan 0")
    end,
  })
end

if vim.fn.has("macunix") == 1 then
  vim.g.mapleader = "_"
end
