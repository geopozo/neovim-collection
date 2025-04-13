local M = {}

-- Writes the contents of the given buffer to a temporary file.
-- Stores the filename in the buffer variable "ipy-tempfile" if not present.
function M.write_buffer_to_temp(editor_buf)
  local buffer_lines = vim.api.nvim_buf_get_lines(editor_buf, 0, -1, false)
  local ok, tmp_filename = pcall(vim.api.nvim_buf_get_var, editor_buf, "ipy-tempfile")
  if not ok then
    tmp_filename = vim.fn.tempname() .. "script.py"
    vim.api.nvim_buf_set_var(editor_buf, "ipy-tempfile", tmp_filename)
  end

  local file = io.open(tmp_filename, "w")
  if not file then
    vim.api.nvim_err_writeln("Error: Could not create temporary file!")
    error("Unhandled error: unable to create temporary file")
    return nil
  end

  for _, line in ipairs(buffer_lines) do
    file:write(line, "\n")
  end
  file:close()

  return tmp_filename
end

return M
