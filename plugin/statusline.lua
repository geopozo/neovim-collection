-- Statusline showing filetype, attached LSP clients, and Treesitter state.

local function lsp_status(bufnr)
  local names = {}
  for _, client in ipairs(vim.lsp.get_clients({ bufnr = bufnr })) do
    table.insert(names, client.name)
  end
  if #names == 0 then
    return "lsp:-"
  end
  return "lsp:" .. table.concat(names, ",")
end

-- Collects the language of a parser and every injected child parser.
local function collect_languages(parser, langs, seen)
  local lang = parser:lang()
  if not seen[lang] then
    seen[lang] = true
    table.insert(langs, lang)
  end
  for _, child in pairs(parser:children()) do
    collect_languages(child, langs, seen)
  end
  return langs
end

local function treesitter_status(bufnr)
  if not vim.treesitter.highlighter.active[bufnr] then
    return "ts:-"
  end
  local ok, parser = pcall(vim.treesitter.get_parser, bufnr)
  if not ok or not parser then
    return "ts:?"
  end
  return "ts:" .. table.concat(collect_languages(parser, {}, {}), ",")
end

function _G.CollectionStatusline()
  local bufnr = vim.api.nvim_get_current_buf()
  local ft = vim.bo[bufnr].filetype
  if ft == "" then
    ft = "-"
  end
  return table.concat({
    "%<%f %m%r",
    "%=",
    "ft:" .. ft,
    lsp_status(bufnr),
    treesitter_status(bufnr),
    "%l:%c %P ",
  }, "  ")
end

vim.o.laststatus = 2 -- always on, its per pane, maybe try 3
-- %! evaluate rest as command, v:lua lua func
vim.o.statusline = "%!v:lua.CollectionStatusline()"
