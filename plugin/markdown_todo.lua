vim.treesitter.query.set("markdown_inline", "highlights", [[;extends

  ((inline) @cancelled (#match? @cancelled "\\[c\\]") )
  ((inline) @priority (#match? @priority "\\[ \\]\\*") )
]]) -- had trouble adding this below

vim.treesitter.query.set("markdown", "highlights", [[;extends
  (list_item
    (list_marker_minus) @done
    (task_list_marker_checked) @done
    (paragraph) @done
  )

  (list_item
    (list_marker_minus) @skipped
    (paragraph
      (inline) @skipped-txt
    )
    (#match? @skipped-txt "\\[s\\]")
  )
]])

vim.api.nvim_set_hl(0, "@skipped.markdown", { fg = "#DDDD00", strikethrough = true })
vim.api.nvim_set_hl(0, "@skipped-txt.markdown", { fg = "#DDDD00", strikethrough = true })
vim.api.nvim_set_hl(0, "@cancelled.markdown_inline", { fg = "#ff5577", strikethrough = true })
vim.api.nvim_set_hl(0, "@priority.markdown_inline",   { fg = "#ff1111" })
vim.api.nvim_set_hl(0, "@done.markdown", { fg = "#00ff88" })

vim.treesitter.query.set("markdown", "folds", [[
  (section) @fold
]])
