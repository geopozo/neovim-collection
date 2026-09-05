# Neovim-Collection

A small collection of Neovim plugins.

Full reference: `:help neovim-collection` (see `doc/neovim-collection.txt`).

## Install

I use [lazy.nvim](https://github.com/folke/lazy.nvim)
([install guide](https://lazy.folke.io/installation)), which loads plugins from
a Lua spec under *~/.config/nvim/lua/plugins/*.

Example *~/.config/nvim/lua/plugins/init.lua*:

```lua
return {
  -- From a local checkout:
  { dir = vim.fn.expand("~/projects/utilities/neovim-collection.git") },

  -- Or from GitHub (lazy appends .git itself):
  "geopozo/neovim-collection",
}
```

Use one or the other. per repo.

## Markdown TODO highlighting

Adds Treesitter highlight queries for task lists for more color.

| Marker   | Meaning   | Style              |
|----------|-----------|--------------------|
| `[x]`    | done      | green              |
| `[x]*`   | done      | green              |
| `[ ]*`   | priority  | red                |
| `[s]`    | skipped   | yellow, struck out |
| `[c]`    | cancelled | pink, struck out   |

Recomended *init.lua* config:

```lua
vim.filetype.add({ extension = { todo = "markdown" } })

vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function() vim.opt_local.foldmethod = "indent" end,
  -- indent is reliable for todo lists
})

TODOHighlights.apply()
```

### Dev notes

Useful commands when debugging the queries:

- `:InspectTree` (press I for source information)
- `:Inspect` show determined syntax at line
- `:hi @done.markdown_inline` show style for "done" defined by markdown_inline

Markdown uses two Treesitter trees: `markdown` for block structure and
`markdown_inline` for inline content. The `[x]`/`[ ]` markers live in
`markdown_inline`, so most of the queries target that tree.

## PyTemp

A scratch-script workflow built on [uv](https://github.com/astral-sh/uv). You
edit a Python file with a [PEP 723](https://peps.python.org/pep-0723/) inline
script header; the plugin writes it to a temp file and launches IPython through
`uv run` with the header's `requires-python` and `dependencies` applied. If you
are inside a project, `uv` also picks up the project environment.

TLDR: Open up a script+interpretter in a temp copy of the project environment +
whatever dependencies you add in the script header.

Requires `uv` on your `PATH`. IPython is added automatically with
`--with ipython`.

```
:PyTemp [name] [--no-project]
```

Opens a new tab with a fresh script (a random name in the current directory
unless you give one), pre-filled with a PEP 723 header, and starts an IPython
terminal below it. The buffer is wiped when hidden, so save it with `:w` if you
want to keep it.

```
:PyIt [--no-project]
```

Runs the current buffer in IPython. Run it again to restart IPython with your
latest edits; the old process is killed and the same terminal window is reused.
It also works from inside the terminal buffer.

`--no-project` passes `--no-project` to `uv run`, ignoring any surrounding
`pyproject.toml`.

Inside the terminal buffer:

- `<C-w><C-w>` restarts IPython with the current script.
- `<C-w><Up>` jumps back to the window above (leaves terminal mode first).

The exact `uv run` command is echoed when you enter the terminal buffer.

## Psql

```
:Psql [database]
```

Sends the whole current buffer to `psql -X -v ON_ERROR_STOP=1 -d {database}`
on stdin. Output is echoed to the message area; errors are shown with
`vim.notify`. The database is remembered, so after the first call you can run
`:Psql` with no argument.

## Sidecar

```
:SidecarToml
```

Opens *{filename}.meta.toml* next to the current file in a split above, sized
to a third of the window. If the file does not exist it is created with the
schema I use for tagged writing: `name`, `related`, `goal`, `next_step`,
`campaign`, `potential`, `completeness`, `published`, `history`, and `tag`.

## Statusline

Sets a statusline that shows the file, then on the right: filetype, attached
LSP clients, the Treesitter grammars active in the buffer (including injected
ones), and cursor position.

```
src/main.py [+]            ft:python  lsp:pyright,ruff  ts:python  42:7
README.md                  ft:markdown  lsp:-  ts:markdown,lua,markdown_inline  1:1
```

It overwrites `statusline` globally. To use only the pieces in your own
statusline, the function is exposed as `CollectionStatusline()`:

```lua
vim.o.statusline = "%!v:lua.CollectionStatusline()"
```

## Roadmap

See the issues on GitHub.

## Developer notes

For any plugin in lazy's plugin list, including this one:

- *plugin/\*.lua* files run at startup.
- *lua/* holds modules reachable with `require(...)` from anywhere Lua runs,
  including your main *init.lua*.

Here, *plugin/pytemp.lua* just does `require("pytemp")`, which registers the
commands. The other plugins are self-contained scripts under *plugin/*.

To regenerate the help tags after editing *doc/neovim-collection.txt*:

```
nvim --headless -c 'helptags doc' -c q
```
