local M = {}

-- Create or reuse an augroup for displaying mode information.
local mode_group = vim.api.nvim_create_augroup("NewModeMessage", { clear = false })

-- Displays a truncated message when entering a buffer and re-enables mode messages when leaving.
function M.mode_show(bufnr, msg)
  vim.api.nvim_clear_autocmds({ group = mode_group, buffer = bufnr })
  vim.api.nvim_create_autocmd("BufEnter", {
    group = mode_group,
    buffer = bufnr,
    callback = function()
      vim.o.showmode = false
      vim.schedule(function()
        local cols = vim.o.columns
        local truncated = msg:sub(1, cols - 15)
        vim.api.nvim_echo({ { truncated, "None" } }, false, {})
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

return M