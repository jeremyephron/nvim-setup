" Python File Settings

set tabstop=4
set softtabstop=4
set shiftwidth=4

set colorcolumn=80

" Run the current file
nnoremap <Leader>m :w <Bar> !python3 %<CR>

"" Add python docstring with ,p
nnoremap <Leader>p :Pydocstring<CR>
