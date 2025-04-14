local M = {}

-- Deletes buffer after a delay so it is fully detached.
function M.wiper(bufnr)
vim.api.nvim_buf_set_option(bufnr, "bufhidden", "wipe")
  vim.api.nvim_create_autocmd("BufHidden", {
    buffer = bufnr,
    callback = function(args)
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

-- Checks if a buffer with the given name already exists.
function M.name_taken(name)
  for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_get_name(bufnr) == name then
      return bufnr
    end
  end
  return nil
end


function M.manage_writes(bufnr)
  return
--  vim.api.nvim_create_autocmd("BufWriteCmd", {
--    buffer = bufnr,  -- your buffer of interest; usually set dynamically
--    callback = function(args)
--      vim.api.nvim_buf_set_option(bufnr, 'modified', true)
--      return true
--    end
--  })
--  local old_name = vim.api.nvim_buf_get_name(bufnr)
--  local new_name = args.match  -- the target filename for the write
--  print("Names")
--  print(old_name)
--  print(new_name)
--  -- Check if we've allowed a forced write in the past.
--  local ok, allowed_before = pcall(vim.api.nvim_buf_get_var, bufnr, "_allow_simple_write")
--  if not ok then allowed_before = false end
--
--  -- Determine if the write is allowed:
--  -- Allow if:
--  --   (1) the command was forced (e.g. :w!),
--  --   (2) a saveas is happening (filename changes),
--  --   (3) we’ve already had a forced write on this buffer.
--  if (old_name ~= new_name and new_name ~= "") or allowed_before then
--    -- Mark that a forced operation has happened; allow plain :w later.
--    vim.api.nvim_buf_set_var(bufnr, "_allow_simple_write", true)
--    -- Execute the write. Using write! so that the command itself doesn't fail.
--    vim.cmd("write! " .. vim.fn.fnameescape(new_name))
--  else
--    vim.api.nvim_err_writeln("Use :saveas[!] to write this buffer.")
--  end
--  return true  -- cancel further processing (we handled the write)
--end
end
return M
