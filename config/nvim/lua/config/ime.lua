-- IME auto control configuration

local M = {}

-- IME control command path
local ime_cmd = nil

-- Detect available IME control tool
local function detect_ime_tool()
  -- Check for zenhan first (more reliable for Windows IME)
  local zenhan_paths = {
    vim.fn.expand("~/workspace/bin/zenhan.exe"),
    vim.fn.expand("~/bin/zenhan.exe"),
    "/mnt/c/Windows/System32/zenhan.exe",
  }

  for _, path in ipairs(zenhan_paths) do
    if vim.fn.executable(path) == 1 then
      return { cmd = path, type = "zenhan" }
    end
  end

  -- Check for im-select as fallback
  local im_select_paths = {
    vim.fn.expand("~/workspace/bin/im-select.exe"),
    vim.fn.expand("~/bin/im-select.exe"),
    "/mnt/c/Windows/System32/im-select.exe",
  }

  for _, path in ipairs(im_select_paths) do
    if vim.fn.executable(path) == 1 then
      return { cmd = path, type = "im-select" }
    end
  end

  return nil
end

-- Turn IME off
local function ime_off()
  if not ime_cmd then
    return
  end

  if ime_cmd.type == "im-select" then
    -- Try multiple keyboard layout identifiers
    -- Some environments may use different IDs
    local ids = {
      "0x04090409",  -- US keyboard
      "0x04110411",  -- Japanese keyboard - Alphanumeric mode
      "1033",        -- English (United States)
    }

    for _, id in ipairs(ids) do
      vim.fn.system(string.format("%s %s", ime_cmd.cmd, id))
    end
  elseif ime_cmd.type == "zenhan" then
    -- zenhan: turn IME off
    vim.fn.system(ime_cmd.cmd .. " 0")
  end
end

-- Setup
function M.setup()
  ime_cmd = detect_ime_tool()

  if not ime_cmd then
    vim.notify("IME control tool not found (zenhan or im-select)", vim.log.levels.WARN)
    return
  end

  -- Turn IME off when leaving insert mode
  vim.api.nvim_create_autocmd("InsertLeave", {
    pattern = "*",
    callback = function()
      ime_off()
    end,
    desc = "IME off on InsertLeave"
  })

  -- Turn IME off when leaving command/search mode
  vim.api.nvim_create_autocmd("CmdlineLeave", {
    pattern = "[/?]",
    callback = function()
      ime_off()
    end,
    desc = "IME off on CmdlineLeave"
  })
end

return M
