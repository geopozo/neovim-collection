local buffer_util = require("pytemp.buffer")
local display = require("pytemp.display")
local header = require("pytemp.header")
local file_util = require("pytemp.file")

local M = {}

local function run_python_terminal(opts)

  local calling_buf = vim.api.nvim_get_current_buf()
  local calling_name = vim.api.nvim_buf_get_name(calling_buf)

  -- We're often in the editor, but...
  local editor_buf = calling_buf
  local editor_name = calling_name
  -- ... in case we're not
  local ok, check_editor_buf = pcall(vim.api.nvim_buf_get_var, calling_buf, "ipy-editor_buf")
  if ok then
    editor_buf = check_editor_buf
    editor_name = vim.api.nvim_buf_get_var(calling_buf, "ipy-editor_name")
  else
    local bt = vim.api.nvim_buf_get_option(calling_buf, "buftype")
    if not (bt == "" or bt == "acwrite" or bt == "nofile") then
        error("This buffer doesn't seem like it would be python...")
    end
  end

  local tmp_filename = file_util.write_buffer_to_temp(editor_buf)
  local uv_info = header.parse_uv_script_header(editor_buf)

  -- see what the editor thinks its terminal buffer is
  local ok, term_buf = pcall(vim.api.nvim_buf_get_var, editor_buf, "ipy-terminal_buf")
  if ok then -- it had a record
    ok = vim.api.nvim_buf_is_valid(term_buf) -- it is an actual buffer

    ok2, editor_buf_check = pcall(
        vim.api.nvim_buf_get_var,
        term_buf,
        "ipy-editor_buf"
    ) -- it agrees with us

    ok3, editor_name_check = pcall(
        vim.api.nvim_buf_get_var,
        term_buf,
        "ipy-editor_name"
    ) -- it agrees with us

    ok = ok and ok2 and ok3
        and editor_buf_check == editor_buf
        and editor_name_check == editor_name
  end
  if not ok then -- at end, not ok, recorded term_buf invalid, make new
    vim.cmd("belowright split")
    vim.cmd("enew")
    term_buf = vim.api.nvim_get_current_buf()
  else -- we're using an active one, so kill its process
    local ok, job_id = pcall(vim.api.nvim_buf_get_var, term_buf, "terminal_job_id")
    if ok and job_id then
      vim.fn.jobstop(job_id)
      vim.fn.jobwait({ job_id }, -1)
      vim.api.nvim_buf_set_option(term_buf, 'modified', false)
    end
  end

  local prev_win = vim.api.nvim_get_current_win() -- remember where we are
  local prev_buf = vim.api.nvim_get_current_buf()
  local target_win = nil
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if vim.api.nvim_win_get_buf(win) == term_buf then
      target_win = win -- get term_buf's window
      break
    end
  end

  if target_win then -- switch to that
    vim.api.nvim_set_current_win(target_win)
  else
    error("Something went wrong and I'm not sure what")
  end

  -- derive parts of the command from the header
  local parts = {
    "-p \"" .. (uv_info.requires_python or "") .. "\""
  }
  for _, dep in ipairs(uv_info.dependencies) do
    table.insert(parts, "--with \"" .. dep .. "\"")
  end
  local flags = ""
  if opts and opts.args == "--no-project" then
    flags = "--no-project "
  end
  -- reun command and set all of its vars
  local cmd = "uv run " .. flags .. table.concat(parts, " ") .. " --with ipython ipython --theme=pride -i " .. tmp_filename
  local process_nr = vim.fn.termopen(cmd)
  vim.api.nvim_buf_set_name(term_buf, editor_name .. "-ipython")
  vim.api.nvim_buf_set_var(editor_buf, "ipy-terminal_buf", term_buf)
  vim.api.nvim_buf_set_var(term_buf, "ipy-editor_buf", editor_buf)
  vim.api.nvim_buf_set_var(term_buf, "ipy-editor_name", editor_name)
  buffer_util.wiper(term_buf)
  display.mode_show(term_buf, cmd)

  vim.keymap.set('t', '<C-w><Up>', '<C-\\><C-n><C-w><Up>', { noremap = true, buffer = term_buf })
  vim.keymap.set('t', '<C-w><C-w>', function()
    M.run_python_terminal_and_i(opts) -- would this need to take options then
  end, { noremap = true, buffer = term_buf })

  vim.api.nvim_create_autocmd("BufEnter", {
    buffer = term_buf,
    callback = function()
      vim.cmd("startinsert")
    end,
  })

  -- Return to the previous window and buffer.
  vim.api.nvim_set_current_win(prev_win)
  vim.api.nvim_set_current_buf(prev_buf)

  return target_win, cmd
end

-- Runs the terminal and then jumps to it.
function M.run_python_terminal_and_i(opts)
  local target_win, cmd = run_python_terminal(opts)
  vim.api.nvim_set_current_win(target_win)
  vim.cmd("startinsert")
end

-- Create a new Python script in a new tab with a header,
-- then immediately launch the interactive terminal.
function M.new_python_script(opts)
  local name = nil
  local no_project = ""

  for _, arg in ipairs(vim.fn.split(opts.args)) do
    if arg == "--no-project" then
      no_project = "--no-project"
    elseif not name then
      name = arg
    else
      vim.api.nvim_err_writeln("Too many positional arguments")
      return
    end
  end


  name = name or vim.fn.getcwd() .. "/" .. vim.fn.fnamemodify(vim.fn.tempname(), ":t") .. "script.py"
  if buffer_util.name_taken(vim.fn.fnamemodify(name, ":p")) then
    vim.api.nvim_err_writeln("Can't reuse names in PyTemp.")
    return
  end
  vim.cmd("tabnew " .. name)
  local editor_buf = vim.api.nvim_get_current_buf()
  local current_win = vim.api.nvim_get_current_win()
  local header_lines = {
    "",
    "# /// script",
    "# requires-python = \">=3.12\"",
    "# dependencies = []",
    "# ///",
    "",
  }
  vim.api.nvim_buf_set_lines(0, 0, 0, false, header_lines)
  vim.api.nvim_buf_set_option(0, 'modified', false)
  vim.bo.filetype = "python"
  vim.bo.bufhidden = 'wipe'
  buffer_util.wiper(editor_buf)
  buffer_util.manage_writes(editor_buf)
  opts = { args = no_project }
  local _, cmd = run_python_terminal(opts)
  vim.api.nvim_set_current_win(current_win)
  vim.schedule(function()
    vim.api.nvim_echo({ { cmd, "None" } }, false, {})
  end)
end

return M
