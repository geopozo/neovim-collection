vim.treesitter.query.set("markdown_inline", "highlights", [[;extends

  ((inline) @cancelled (#match? @cancelled "\\[c\\]") (#set! "priority" 130))
  ((inline) @priority (#match? @priority "\\[ \\]\\*") (#set! "priority" 130))
  ((inline) @done (#match? @done "\\[x\\]\\*") (#set! "priority" 130))
  ((inline) @skipped (#match? @skipped "\\[s\\]") (#set! "priority" 130))
]]) -- had trouble adding this below, but maybe it would work with priority

vim.treesitter.query.set("markdown", "highlights", [[;extends
  (list_item
    (list_marker_minus) @done
    (task_list_marker_checked) @done
    (paragraph) @done
  )
]])

vim.api.nvim_set_hl(0, "@skipped.markdown_inline", { fg = "#DDDD00", strikethrough = true })
vim.api.nvim_set_hl(0, "@cancelled.markdown_inline", { fg = "#ff5577", strikethrough = true })
vim.api.nvim_set_hl(0, "@priority.markdown_inline",   { fg = "#ff1111" })
vim.api.nvim_set_hl(0, "@done.markdown", { fg = "#00ff88" })
vim.api.nvim_set_hl(0, "@done.markdown_inline", { fg = "#00ff88" })

vim.treesitter.query.set("markdown", "folds", [[
  (section) @fold
]])
