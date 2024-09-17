set nocompatible "more vim-like, less vi-like

"https://github.com/junegunn/vim-plug/wiki/tips
"Install vim-plug if not found
if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
endif

" Run PlugInstall if there are missing plugins
autocmd VimEnter * if len(filter(values(g:plugs), '!isdirectory(v:val.dir)'))
  \| PlugInstall --sync | source $MYVIMRC
\| endif

" plugins
call plug#begin()
Plug 'junegunn/goyo.vim'
Plug 'preservim/nerdtree'
Plug 'tpope/vim-fugitive'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'bling/vim-bufferline'
Plug 'hashivim/vim-terraform'
call plug#end()

"wayland clipboard
nnoremap <C-@> :call system("wl-copy", @")<CR>

set backspace=2
"reload vimrc on F5, spelling on F6
nnoremap <F5> :so $MYVIMRC<cr>
map <F6> :setlocal spell! spelllang=en_us<CR>
"colors
syntax enable
"colorscheme quiet
set background=dark
set t_Co=256 "256 colors in terminal
set cc=80
hi Normal guibg=NONE
hi Normal ctermbg=NONE

" strip trailing whitepace
fun! TrimWhitespace()
    let l:save = winsaveview()
    keeppatterns %s/\s\+$//e
    call winrestview(l:save)
endfun
highlight ExtraWhitespace ctermbg=darkgray guibg=darkgray
match ExtraWhitespace /\s\+$/
autocmd BufWritePre * if !&binary | call TrimWhitespace() | endif

set number "line numberings
set smartindent "indent on new line

"tab options
set tabstop=4
set shiftwidth=4
"set expandtab
filetype indent on "filetype-specific indents
set linebreak

set mouse=a
set wildmode=longest,list,full "completion mode
set wildmenu "command-line completion
set path+=** "add current directory to path

set splitright splitbelow "vsplit/split: always put new windows below/right
" new vsplit
map <C-w>N :vnew<CR>
"window movement
map <C-h> <C-w>h
map <C-j> <C-w>j
map <C-k> <C-w>k
map <C-l> <C-w>l

"search: ignore case, except when caps are used
set ignorecase
set smartcase
set incsearch "search as characters are entered
set hlsearch "highlight matches

" Reopen the last edited position in files
au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif

"statusline
let g:airline_theme='minimalist'
let g:airline_extensions = ['bufferline']
"let g:airline#extensions#tabline#enabled=1
"let g:airline#extensions#whitespace#enabled=0

"custom keymaps
let mapleader=" "
inoremap jj <esc>
nnoremap bn :bnext<cr>
nnoremap bN :bprevious<cr>
nnoremap <F4> :! %<cr>
inoremap <F2> <esc>:NERDTreeToggle<cr>
nnoremap <F2> :NERDTreeToggle<cr>
nnoremap <leader>f :NERDTreeToggle<cr>
nnoremap bD :set background=dark<cr>
nnoremap bL :set background=light<cr>
tnoremap <ESC> <C-w>:q!<CR>
nnoremap <leader><space> :nohlsearch<CR>
nnoremap <leader>r :so $MYVIMRC<cr>
nnoremap <leader>D :Gdiff<cr>
nnoremap <leader>B :G blame<cr>
nnoremap <leader>gf :edit %:h/<cfile><CR>
" move down on wrapped lines
nnoremap j gj
nnoremap k gk

"run file based on language
autocmd FileType python map <buffer> <F4> :w<CR>:exec '!clear; python3' shellescape(@%, 1)<CR>
autocmd FileType python imap <buffer> <F4> <esc>:w<CR>:exec '!clear;python3' shellescape(@%, 1)<CR>
autocmd FileType shell map <buffer> <F4> :w<CR>:exec '!clear;bash' shellescape(@%, 1)<CR>
autocmd FileType shell imap <buffer> <F4> <esc>:w<CR>:exec '!clear;bash' shellescape(@%, 1)<CR>
autocmd FileType html map <buffer> <F4> :w<CR>:exec '!clear;firefox' shellescape(@%, 1)<CR>
autocmd FileType html imap <buffer> <F4> <esc>:w<CR>:exec '!clear;firefox' shellescape(@%, 1)<CR>
autocmd FileType rust map <buffer> <F4> :w<CR>:exec '!rs' shellescape(@%, 1)<CR>
autocmd FileType rust imap <buffer> <F4> <esc>:w<CR>:exec '!rs' shellescape(@%, 1)<CR>
autocmd FileType go map <buffer> <F4> :w<CR>:exec '!g' shellescape(@%, 1)<CR>
autocmd FileType go imap <buffer> <F4> <esc>:w<CR>:exec '!g' shellescape(@%, 1)<CR>
autocmd FileType c map <buffer> <F4> :w<CR>:exec '!c' shellescape(@%, 1)<CR>
autocmd FileType c imap <buffer> <F4> <esc>:w<CR>:exec '!c' shellescape(@%, 1)<CR>

"formatters
augroup configgroup
    autocmd!
    autocmd VimEnter * highlight clear SignColumn
    autocmd FileType vala setlocal syntax=vala
    autocmd FileType yaml setlocal tabstop=2
    autocmd FileType yaml setlocal expandtab
    autocmd FileType yaml setlocal shiftwidth=2
    autocmd FileType yaml setlocal softtabstop=2
    autocmd FileType yaml setlocal expandtab
    autocmd FileType ruby setlocal tabstop=2
    autocmd FileType ruby setlocal shiftwidth=2
    autocmd FileType ruby setlocal softtabstop=2
    autocmd FileType ruby setlocal commentstring=#\ %s
    autocmd FileType python setlocal commentstring=#\ %s
    autocmd BufEnter *.cls setlocal filetype=java
    autocmd BufEnter Makefile setlocal noexpandtab
augroup END

