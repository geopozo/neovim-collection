# Neovim-Collection

## Install

I use [lazy](https://github.com/folke/lazy.nvim)
 [install guide](https://lazy.folke.io/installation) which installs plugins,
including this one, from a JSON-ish (but lua) specification:
in *.config/nvim/lua/plugins/*.

In my case, I store these three files in my dot-management system.

### example *.config/nvim/lua/plugins/init.lua*:

```lua
return {
  ...,
  {
    dir = "~/projects/utilities/neovim-collection.git",
  },
  "geopozo/neovim-collection", -- same thing, but lazy auto-appends .git
}
```

NB: Lazy config can take a `dir =` directive, otherwise it downloads repos.

## Markdown

We add extra syntax highlight and override folds to only do `#` sections,
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

## ROADMAP

See issues on github.

Also, it would be nice to see,

1. logs
1. when a setting gets overriden, we know how and where

## Developmer Notes

For any plugin (like this one) that you include in Lazy's list of plugins:

_plugin/*.lua_ are loaded at boot.

_lua/_ are lua modules are available through `require(...)` (anywhere that runs
lua, such as the main _init.lua_ in _.config/nvim_).

Here, my _plugin/_ scripts `require(...)` everything in _lua/_ at boot.
