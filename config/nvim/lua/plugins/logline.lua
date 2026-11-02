-- Development mode: use local repository directly via runtimepath
-- vim.opt.runtimepath:prepend('/home/kiffveef/workspace/github.com/kiffveef/logline')

-- Production mode: use MiniDeps with GitHub repository
local add = MiniDeps.add
add({ source = 'git@github.com:kiffveef/logline.git', name = 'logline' })

require('logline').setup()
