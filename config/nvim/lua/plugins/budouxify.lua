-- budouxify.nvim: Japanese text motion enhancement using BudouX
-- https://github.com/atusy/budouxify.nvim

local add = MiniDeps.add

-- Install budoux.lua (dependency)
add({
  source = "atusy/budoux.lua",
})

-- Install budouxify.nvim
add({
  source = "atusy/budouxify.nvim",
})

-- Setup will be done in later() block
MiniDeps.later(function()
  -- Check if budouxify is available
  local ok, budouxify = pcall(require, "budouxify.motion")
  if not ok then
    vim.notify("budouxify.nvim not loaded", vim.log.levels.WARN)
    return
  end

  -- Setup keymaps for Japanese text motion
  -- W: Move to next word head (forward)
  vim.keymap.set('n', 'W', function()
    budouxify.find_forward({ head = true })
  end, { desc = "BudouX: Next word head" })

  -- E: Move to next word end (forward)
  vim.keymap.set('n', 'E', function()
    budouxify.find_forward({ head = false })
  end, { desc = "BudouX: Next word end" })

  -- B: Move to previous word head (backward)
  vim.keymap.set('n', 'B', function()
    budouxify.find_backward({ head = true })
  end, { desc = "BudouX: Previous word head" })

  -- Visual mode mappings
  vim.keymap.set('x', 'W', function()
    budouxify.find_forward({ head = true })
  end, { desc = "BudouX: Next word head (visual)" })

  vim.keymap.set('x', 'E', function()
    budouxify.find_forward({ head = false })
  end, { desc = "BudouX: Next word end (visual)" })

  vim.keymap.set('x', 'B', function()
    budouxify.find_backward({ head = true })
  end, { desc = "BudouX: Previous word head (visual)" })
end)
