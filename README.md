# Neovim-Collection

## Install

I use [lazy](https://github.com/folke/lazy.nvim)
 [install guide](https://lazy.folke.io/installation) which installs plugins,
including this one, from a simple list.

NB: Lazy config can take a `dir =` directive, otherwise it downloads repos.

example *plugins/init.lua* (see the install guide above):

```lua
return {
  ...,
  {
    dir = "~/projects/utilities/neovim-collection.git",
  },
  "geopozo/neovim-collection", -- same thing, but lazy auto-appends .git
}
```

## Markdown

We add extra syntax highlight and override folds to only do # sections,
as otherwise behavior is wonky.

### Dev Notes

Some commands to help debug:

`:InspectTree` (use 2x `[` and `]` to switch between trees)
`:Inspect`
`:hi @done.markdown_inline`

Markdown uses two trees: `markdown` and `markdown_inline`.

## PyTemp

This relies on [uv](https://github.com/astral-sh/uv). It opens up a temporary
script and integrates those dependencies with your project. It opens an ipython
terminal for you.

`PyIt [--no-project]`

Open ipython terminal for a current script you have open.

`PyTemp [--no-project]`

Open a new tab w/ a blank script file and a ipython terminal.

## Sidecar

Opens up a .meta.toml for the current file in its directory w/ the schema that I
use for taged writing.

# ROADMAP

See issues on github.

Also, it would be nice to see like,

1. logs
1. when a setting gets overriden, we know how and where

# Developmer Notes

plugin/ always gets loaded at start.

lua/ are lua modules that are available through `require(...)`

I have my plugin/ scripts load the `require(...)` for the lua folder.
