local terminal = require("pytemp.terminal")

vim.api.nvim_create_user_command("PyIt", terminal.run_python_terminal_and_i, {})
vim.api.nvim_create_user_command("PyTemp", terminal.new_python_script, { nargs = 1 })

return {
  terminal = terminal,
}
