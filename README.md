`~/.config/nvim/...` for config files

`~/.local/share/site/pack/all/start/...` for downloading plugins

## General

https://www.github.com/geopozo/neovim-collection

`:PyTemp [--no-project] [NAME]`
`:PyIt [--no-project]`
`:Source` ... fragile!

https://github.com/nvim-treesitter/nvim-treesitter

Treesitter plugin needs to be installed. It's built into neovim, apparently, but
sometimes I find myself installing grammars with pacman/yay (system package
manager) and sometimes with neovim's `:TSInstall`.

It needs to be config'd separately and there is a config here.

https://www.github.com/neovim/nvim-lspconfig

## Python


## Markdown

https://github.com/ixru/nvim-markdown

gst-launch-1.0 ximagesrc ! video/x-raw,framerate=30/1 ! videoconvert ! x264enc tune=zerolatency bitrate=5000 speed-preset=ultrafast ! rtph264pay ! udpsink host=127.0.0.1 port=5000

gst-launch-1.0 udpsrc port=5000 caps="application/x-rtp" ! rtph264depay ! avdec_h264 ! autovideosink


