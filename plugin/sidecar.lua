vim.api.nvim_create_user_command('SidecarToml', function()
  local file = vim.api.nvim_buf_get_name(0)
  if file == '' then
    print('No file in current buffer')
    return
  end

  -- %NAME = filename (with extension), same dir
  local dir  = vim.fn.fnamemodify(file, ':h')
  local name = vim.fn.fnamemodify(file, ':t')
  local side = dir .. '/' .. name .. 'meta.toml'

  -- Create sidecar if missing
  if not vim.uv.fs_stat(side) then
    local ok, fh = pcall(io.open, side, 'w')
    if not ok or not fh then
      print('Failed to create sidecar: ' .. side)
      return
    end
    fh:write('# metadata for ' .. name .. '\n')
    fh:write('name = "' .. name:gsub('"','\\"') .. '"\n')
    fh:close()
  end

  -- Open above in a 1/3-height split
  local cur_h = vim.api.nvim_win_get_height(0)
  local target = math.max(3, math.floor(cur_h / 3))
  vim.cmd('aboveleft split ' .. vim.fn.fnameescape(side))
  vim.cmd('resize ' .. target)
end, { desc = 'Open or create %NAME.meta.toml above at 1/3 height' })
