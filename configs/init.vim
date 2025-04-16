set backspace=indent,eol,start

" the follow will let you look for .vimrc in your local folder
set path+=**

set mouse=a
set number
set cursorline
set textwidth=80
set formatoptions=tcqj " being overridden
set colorcolumn=-3,-2,-1

set laststatus=2
set statusline=
set statusline+=%-3.3n\                      " buffer number
set statusline+=%f\                          " filename
set statusline+=%h%m%r%w                     " status flags
set statusline+=\[%{strlen(&ft)?&ft:'none'}] " file type
set statusline+=%=                           " right align remainder
set statusline+=0x%-8B                       " character value
set statusline+=%-14(%l,%c%V%)               " line, character
set statusline+=%<%P                         " file position

set nolist
set wildmenu
nnoremap <C-Space> :noh<CR>
set clipboard=unnamedplus

lua require('config')

set foldlevel=99            " start with all folds open
set foldenable              " enable folding, but don’t close anything by default
set foldopen=               " disables auto-opening on cursor move
set foldclose=

