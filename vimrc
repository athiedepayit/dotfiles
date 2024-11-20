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
Plug 'ap/vim-buftabline'
Plug 'rafi/awesome-vim-colorschemes'
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
set background=dark
set t_Co=256 "256 colors in terminal
set cc=80
colorscheme paramount
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
"set laststatus=2
"let g:bufferline_echo=0
"let g:bufferline_active_buffer_left='*'
"let g:bufferline_active_buffer_right=''
"autocmd VimEnter * let &statusline='%{bufferline#refresh_status()}'.bufferline#get_status_string()

"custom keymaps
let mapleader=" "
inoremap jj <esc>
nnoremap bn :bnext<cr>
nnoremap bN :bprevious<cr>
nnoremap bx :bdelete<cr>
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

let g:netrw_banner=0
let g:netrw_browse_split=4
let g:netrw_altv=1
let g:netrw_liststyle=3
let g:netrw_list_hide=netrw_gitignore#Hide()
"let g:netrw_list_hide.=',\(^\|\s\s\)\zs\.\S\+'
let g:netrw_list_hide.=',\(^\|\s\s\)\zs\+'

"command! MakeTags !ctags -R .
