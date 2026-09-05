
local last_psql_db

vim.api.nvim_create_user_command("Psql", function(opts)
  local db = opts.args ~= "" and opts.args or last_psql_db

  if not db then
    vim.notify("Psql: specify a database", vim.log.levels.ERROR)
    return
  end

  last_psql_db = db

  local sql = vim.api.nvim_buf_get_lines(0, 0, -1, false)

  vim.system({
    "psql",
    "-X",
    "-v", "ON_ERROR_STOP=1",
    "-d", db,
    "-f", "-",
  }, {
    stdin = sql,
    text = true,
  }, function(result)
    vim.schedule(function()
      if result.stdout and result.stdout ~= "" then
        vim.api.nvim_echo({ { result.stdout } }, true, {})
      end

      if result.stderr and result.stderr ~= "" then
        vim.notify(
          result.stderr,
          result.code ~= 0 and vim.log.levels.ERROR or vim.log.levels.INFO
        )
      end
      if result.code ~= 0 then
        vim.notify(
          "psql exited with code " .. result.code,
          vim.log.levels.ERROR
        )
      end
    end)
  end)
end, {
  nargs = "?",
  desc = "Run current buffer through psql",
})
