" Disable compatibility with VI
set nocompatible

" Enable syntax higlighting
syntax on
" Set colorscheme

colorscheme evening

" Tabs and spaces
set tabstop=4 softtabstop=0 expandtab shiftwidth=4 smarttab autoindent

" Show line numbers
set number

" Show line and column on cursor position
set ruler

" Highlight unwanted tabs and spaces
set list
set listchars=tab:»·,trail:·

" Prefer Unix format over DOS
set fileformats=unix,dos

" Use UTF-8
set encoding=utf-8
set fileencoding=utf-8

" Remove BOMs
set nobomb

" Highlight search results
set hlsearch

" Function to transform CRLF (DOS) line endings to CR (Unix)
"   https://stackoverflow.com/questions/5357330/how-can-i-setup-vim-to-automatically-convert-the-line-endings-of-any-text-file-i/5361702#5361702
"
" dos2unix ^M
fun! Dos2unixFunction()
    let _s=@/
    let l = line(".")
    let c = col(".")
    try
        set ff=unix
        w!
        "%s/\%x0d$//e
    catch /E32:/
        echo "Sorry, the file is not saved."
    endtry
    let @/=_s
    call cursor(l, c)
endfun
com! Dos2Unix keepjumps call Dos2unixFunction()
au BufReadPost * keepjumps call Dos2unixFunction()

