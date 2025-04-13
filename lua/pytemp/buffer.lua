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

return M


-- we don't deal with saveas right now
--vim.api.nvim_create_autocmd("BufWritePost", {
--  callback = function(args)
--    if args.match ~= "" and not vim.api.nvim_buf_get_name(args.buf):match("^%[") then
--      -- Likely a real save, not an unnamed buffer
--      print("Possibly a save-as:", args.match)
--    end
--  end,
--})

-- But we could, catch the write to a file name, look for our buffer in the terminal,
--  and change its version of the name there
