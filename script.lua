-- since vim.bo.bufhidden = 'wipe' doesn't always work
-- here's a follow up that deletes a buffer
-- but after a delay to make sure its gone through its
-- whole closing process
function wiper(bufnr)
  vim.api.nvim_create_autocmd("BufHidden", {
    buffer = bufnr,
    callback = function(args)
      -- Defer to allow Neovim to fully detach the buffer
      vim.schedule(function()
        local is_visible = false
        for _, win in ipairs(vim.api.nvim_list_wins()) do
          if vim.api.nvim_win_get_buf(win) == args.buf then
            is_visible = true
            break
          end
        end
        if not is_visible and vim.api.nvim_buf_is_loaded(args.buf) then
          vim.api.nvim_buf_delete(args.buf, { force = true })
        end
      end)
    end,
  })
end
local mode_group = vim.api.nvim_create_augroup("NewModeMessage", { clear = false })
function mode_show(bufnr, msg)
  vim.api.nvim_clear_autocmds({
    group = mode_group,
    buffer = bufnr,
  })
  vim.api.nvim_create_autocmd("BufEnter", {
    group = mode_group,
    buffer = bufnr,
    callback = function()
      vim.o.showmode = false
      vim.schedule(function()
        local cols = vim.o.columns
        local truncated = msg:sub(1, cols-15)
        vim.api.nvim_echo({{ truncated, "None" }}, false, {})
      end)
    end,
  })

  vim.api.nvim_create_autocmd("BufLeave", {
    buffer = bufnr,
    callback = function()
      vim.o.showmode = true
    end,
  })
end

function parse_uv_script_header(bufnr)
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
        -- Python version
        local py_ver = clean:match('^requires%-python%s*=%s*"([^"]+)"')
        if py_ver then
          requires_python = py_ver
        end

        -- Start dependencies block
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

  -- Strip all whitespace
  dependencies_str = dependencies_str:gsub("%s", "")

  -- Parse quoted strings into a list
  local dependencies = {}
  for dep in dependencies_str:gmatch('"([^"]+)"') do
    table.insert(dependencies, dep)
  end

  return {
    requires_python = requires_python,
    dependencies = dependencies,
  }
end



-- don't let people open stuff twice with PyTemp
function name_taken(name)
  -- Iterate through all buffers
  for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
    -- Check if the buffer's name matches the given name
    local name2 = vim.api.nvim_buf_get_name(bufnr)
    if name2 == name then
      return bufnr
    end
  end
  return nil  -- Return nil if no buffer with the given name is found
end

local function write_buffer_to_temp(editor_buf)

  local buffer_lines = vim.api.nvim_buf_get_lines(editor_buf, 0, -1, false)

  -- Look for temp file and if not create
  local ok, tmp_filename = pcall(vim.api.nvim_buf_get_var, editor_buf, "ipy-tempfile")
  if not ok then
    tmp_filename = vim.fn.tempname() .. "script.py"
    vim.api.nvim_buf_set_var(editor_buf, "ipy-tempfile", tmp_filename)
  end

  -- Write buffer contents to the temporary file.
  local file = io.open(tmp_filename, "w")
  if not file then
    vim.api.nvim_err_writeln("Error: Could not create temporary file!")
    error("Unhandled")
    return nil
  end
  for _, line in ipairs(buffer_lines) do
    file:write(line, "\n")
  end
  file:close()

  return tmp_filename
end

local function run_python_terminal()

  local calling_buf = vim.api.nvim_get_current_buf()
  local calling_name = vim.api.nvim_buf_get_name(calling_buf)
  local calling_type = vim.api.nvim_buf_get_option(calling_buf, "buftype")

  -- this is the is editor branch
  local editor_buf = calling_buf
  local editor_name = calling_name

  local ok, check_editor_buf = pcall(
    vim.api.nvim_buf_get_var, calling_buf, "ipy-editor_buf"
  )

  if ok then
    editor_buf = check_editor_buf
    editor_name = vim.api.nvim_buf_get_var(calling_buf, "ipy-editor_name")
  end


  local tmp_filename = write_buffer_to_temp(editor_buf)
  local uv_info = parse_uv_script_header(editor_buf)

  local ok, term_buf = pcall(
    vim.api.nvim_buf_get_var, editor_buf, "ipy-terminal_buf"
  )
  if ok then
    ok = vim.api.nvim_buf_is_valid(term_buf)
  end
  if not ok then
    term_buf = nil
  else
    local ok, check_editor_buf = pcall(
      vim.api.nvim_buf_get_var, term_buf, "ipy-editor_buf"
    )
    if not ok or check_editor_buf ~= editor_buf then
      ok = false
      term_buf = nil
    else
      local ok, check_editor_name = pcall(
        vim.api.nvim_buf_get_var, term_buf, "ipy-editor_name"
      )
      if not ok or check_editor_name ~= editor_name then
        ok = false
        term_buf = nil
      end
    end
  end

  if not ok then
    vim.cmd("belowright split")
    -- Start new buffer
    vim.cmd("enew")
    term_buf = vim.api.nvim_get_current_buf()
  else
    local ok, val = pcall(vim.api.nvim_buf_get_var, term_buf, "terminal_job_id")
    if ok and val then
      vim.fn.jobstop(val)
      vim.fn.jobwait({ job_id }, -1)
      vim.api.nvim_buf_set_option(term_buf, 'modified', false)
    end
  end

  -- Save current window and buffer
  local prev_win = vim.api.nvim_get_current_win()
  local prev_buf = vim.api.nvim_get_current_buf()
  -- Find a window showing the target buffer
  local target_win = nil
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if vim.api.nvim_win_get_buf(win) == term_buf then
      target_win = win
      break
    end
  end

  if target_win then
    -- Switch to the window
    vim.api.nvim_set_current_win(target_win)
  end

  local parts = {
    "-p \"" .. uv_info.requires_python .. "\""
  }

  for _, dep in ipairs(uv_info.dependencies) do
    table.insert(parts, "--with \"" .. dep .. "\"")
  end

  cmd = "uv run " .. table.concat(parts, " ") .. " --with ipython ipython --theme=pride -i " .. tmp_filename
  local process_nr = vim.fn.termopen(cmd)

  vim.api.nvim_buf_set_name(term_buf, editor_name .. "-ipython")
  vim.api.nvim_buf_set_var(editor_buf, "ipy-terminal_buf", term_buf)
  vim.api.nvim_buf_set_var(term_buf, "ipy-editor_buf", editor_buf)
  vim.api.nvim_buf_set_var(term_buf, "ipy-editor_name", editor_name)
  vim.bo.bufhidden = 'wipe'
  wiper(term_buf)
  mode_show(term_buf, cmd)
  vim.keymap.set('t', '<C-w><Up>', '<C-\\><C-n><C-w><Up>', { noremap = true, buffer = term_buf })
  vim.keymap.set('t', '<C-w><C-w>', function()
    run_python_terminal()
  end, { noremap = true, buffer = term_buf })
  vim.api.nvim_create_autocmd("BufEnter", {
    buffer = term_buf,
    callback = function()
      vim.cmd("startinsert")
    end,
  })
  -- Return to previous window and buffer
  vim.api.nvim_set_current_win(prev_win)
  vim.api.nvim_set_current_buf(prev_buf)

  return target_win, cmd
end

local function run_python_terminal_and_i()
  target_win, cmd = run_python_terminal()
  vim.api.nvim_set_current_win(target_win)
  vim.cmd("startinsert")
end

-- Define a function to run the Python script interactively in a terminal split.
local function new_python_script(args)
  -- Open new tab

  if name_taken(vim.fn.fnamemodify(args.args, ":p")) then
    vim.api.nvim_err_writeln("Can't reuse names in PyTemp.")
    return
  end
  vim.cmd("tabnew " .. args.args)

  -- Define the lines to insert
  local header = {
    "",
    "# /// script",
    "# requires-python = \">=3.12\"",
    "# dependencies = []",
    "# ///",
    "",
  }
  -- TODO inject the project name if we are in one
  -- TODO also get current requires python

  -- Set the lines at the top of the buffer (line 0)
  vim.api.nvim_buf_set_lines(0, 0, 0, false, header)
  vim.api.nvim_buf_set_option(0, 'modified', false)
  vim.bo.filetype = "python"
  vim.bo.bufhidden = 'wipe'
  wiper(vim.api.nvim_get_current_buf())

  local current_win = vim.api.nvim_get_current_win()
  _, cmd = run_python_terminal()
  vim.api.nvim_set_current_win(current_win)
  vim.schedule(function()
    vim.api.nvim_echo({{ cmd, "None" }}, false, {})
  end)
end

-- Create a user command :py that calls the above function.
vim.api.nvim_create_user_command("PyIt", run_python_terminal_and_i, {})
vim.api.nvim_create_user_command("PyTemp", new_python_script, {nargs = 1})

