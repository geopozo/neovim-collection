if vim.fn.executable("ruff-lsp") ~= 1 then
  error("ruff-lsp is not installed or not in PATH")
end

-- Configure `ruff-lsp`.
-- See: https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#ruff_lsp
-- For the default config, along with instructions on how to customize the settings
require('lspconfig').ruff.setup {
  init_options = {
    settings = {
      -- Any extra CLI arguments for `ruff` go here.
      args = {},
    }
  }
}

vim.filetype.add({
  extension = {
    todo = "markdown",
  },
})

vim.diagnostic.config({
  virtual_text = true,  -- Enable inline diagnostics
  signs = true,         -- Enable signs in the sign column
  underline = true,     -- Underline the problematic code
  update_in_insert = false, -- Avoid distracting updates while typing
})
