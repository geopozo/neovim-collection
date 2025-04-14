" only works if todo is registered as syntax for markdown as well
syntax match ToDoDone /\s*- \[x\].*$/ containedin=ALL contained
highlight ToDoDone ctermfg=Green guifg=Green

syntax match ToDoSkipped /\s*- \[s\].*$/ containedin=ALL contained
highlight ToDoSkipped ctermfg=208 guifg=#FF8C00

syntax match ToDoCancelled /\s*- \[c\].*$/ containedin=ALL contained
highlight ToDoCancelled ctermfg=Grey guifg=Grey
