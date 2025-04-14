vim.api.nvim_create_user_command("Source", function()
  local file = vim.api.nvim_buf_get_name(0)
  local is_real_file = file ~= "" and vim.fn.filereadable(file) == 1

  local pwd = vim.fn.getcwd()
  package.path = pwd .. "/?.lua;" .. pwd .. "/?/init.lua;" .. package.path

  if is_real_file then
    local dir = vim.fn.fnamemodify(file, ":h:t")
    for name in pairs(package.loaded) do
      if name == dir or name:match("^" .. dir:gsub("-", "%%-") .. "%.") then
        package.loaded[name] = nil
      end
    end
  end

  vim.cmd("source %")
end, {})

