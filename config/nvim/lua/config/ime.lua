-- ========================================
-- IME自動制御(WSLからWindowsのIMEをオフにする)
-- ========================================

-- im-selectは環境によって通るIDが違うため、順に全部試す
local im_select_ids = {
  -- US keyboard
  "0x04090409",
  -- Japanese keyboard - Alphanumeric mode
  "0x04110411",
  -- English (United States)
  "1033",
}

-- 前のIDの切り替えが終わってから次を送り、旧版と同じ順序で適用されるようにする
local function run_im_select(cmd, index)
  if index > #im_select_ids then
    return
  end
  vim.system({ cmd, im_select_ids[index] }, {}, function()
    run_im_select(cmd, index + 1)
  end)
end

local function setup_autocmds(ime_off)
  local group = vim.api.nvim_create_augroup("config_ime", { clear = true })
  vim.api.nvim_create_autocmd("InsertLeave", {
    group = group,
    callback = ime_off,
    desc = "IME off on InsertLeave",
  })
  vim.api.nvim_create_autocmd("CmdlineLeave", {
    group = group,
    -- 旧版の"[/?]"は?に一致せず、素の?は任意の1文字(:も含む)に一致するためエスケープする
    pattern = { "/", "\\?" },
    callback = ime_off,
    desc = "IME off on leaving search",
  })
end

-- 見つかったツールのパスに応じて、ノーマルモードに戻ったときの処理を登録する
local function setup_tool(path)
  -- Windowsのexeを起動するとWSLでは数十ms掛かり、同期実行だとノーマルモードに戻るたびに固まるため非同期で投げる
  if vim.fs.basename(path) == "zenhan.exe" then
    setup_autocmds(function()
      vim.system({ path, "0" })
    end)
    return
  end
  setup_autocmds(function()
    run_im_select(path, 1)
  end)
end

-- WSLではPATH探索が/mnt/c配下を走査して1回40ms以上掛かるため、別プロセスで探して起動中のUIを止めない
MiniDeps.later(function()
  if vim.fn.has("wsl") == 0 then
    return
  end

  -- ||でつなぎ、zenhan.exeが見つかればim-select.exeは探さない
  local script = "command -v zenhan.exe || command -v im-select.exe"
  vim.system({ "sh", "-c", script }, { text = true }, function(result)
    local path = vim.trim(result.stdout or "")
    if path == "" then
      return
    end
    vim.schedule(function()
      setup_tool(path)
    end)
  end)
end)
