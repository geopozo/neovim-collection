local M = {}

-- Parses a special header in the first 30 lines of the buffer.
-- Looks for python version requirements and a list of dependencies.
function M.parse_uv_script_header(bufnr)
  bufnr = bufnr or 0
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, 30, false)
  local in_block = false
  local requires_python = nil
  local dependencies_str = ""
  local in_deps = false

  for _, line in ipairs(lines) do
    if line:match("^# /// script") then
      in_block = true
    elseif line:match("^# ///") and in_block then
      break
    elseif in_block then
      local clean = line:match("^#%s*(.*)")
      if clean then
        local py_ver = clean:match('^requires%-python%s*=%s*"([^"]+)"')
        if py_ver then
          requires_python = py_ver
        end

        if clean:match('^dependencies%s*=%s*%[') then
          in_deps = true
          dependencies_str = clean:match('%[(.*)') or ""
        elseif in_deps then
          local end_bracket = clean:match('(.*)%]')
          if end_bracket then
            dependencies_str = dependencies_str .. end_bracket
            in_deps = false
          else
            dependencies_str = dependencies_str .. clean
          end
        end
      end
    end
  end

  -- Remove all whitespace and parse dependencies as quoted strings.
  dependencies_str = dependencies_str:gsub("%s", "")
  local dependencies = {}
  for dep in dependencies_str:gmatch('"([^"]+)"') do
    table.insert(dependencies, dep)
  end

  return {
    requires_python = requires_python,
    dependencies = dependencies,
  }
end

return M
