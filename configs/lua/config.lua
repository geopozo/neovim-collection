if vim.fn.executable("ruff") ~= 1 then
  error("ruff is not installed or not in PATH")
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

vim.diagnostic.config({
  virtual_text = true,  -- Enable inline diagnostics
  signs = true,         -- Enable signs in the sign column
  underline = true,     -- Underline the problematic code
  update_in_insert = false, -- Avoid distracting updates while typing
})

require("nvim-treesitter.configs").setup({
  ensure_installed = { "lua", "python", "vim", "c", "rust", "markdown", "bash", "json"},
  highlight = {
    enable = true,
    disable = { "markdown", "help" },  -- disable for these filetypes
  },
  indent = {
    enable = true,
    disable = { "markdown" },
  },
  incremental_selection = {
    enable = true,
    disable = { "markdown" },
    keymaps = {
      init_selection = "<CR>",
      node_incremental = "<CR>",
      scope_incremental = "<TAB>",
      node_decremental = "<BS>",
    },
  },
})

vim.o.foldmethod = "expr"
vim.o.foldexpr = "nvim_treesitter#foldexpr()"

vim.filetype.add({
  extension = {
    todo = "markdown",
  },
})
