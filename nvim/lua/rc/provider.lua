local env = vim.env
local progs = {
  python_host_prog = env.PYENV_ROOT .. "/versions/neovim2/bin/python",
  python3_host_prog = env.PYENV_ROOT .. "/versions/neovim3/bin/python",
  ruby_host_prog = env.RBENV_ROOT .. "/versions/3.2.1/bin/neovim-ruby-host",
  node_host_prog = env.NODENV_ROOT .. "/versions/18.12.1/bin/neovim-node-host",
  loaded_perl_provider = 0,
}

for k, v in pairs(progs) do
  vim.g[k] = v
end
