" Basic vim settings {{{
" =======================================================================

" tarted as "evim", evim.vim will already have done these settings.
if v:progname =~? "evim"
  finish
endif


" Use Vim settings, rather than Vi settings (much better!).
" This must be first, because it changes other options as a side effect.
set nocompatible

" keep 50 lines of command line history.
set history=50

" enable settings embedded in the files.
set modeline

" Only do this part when compiled with support for autocommands.
if has("autocmd")
  " Enable file type detection.
  " Use the default filetype settings, so that mail gets 'tw' set to 72,
  " 'cindent' is on in C files, etc.
  " Also load indent files, to automatically do language-dependent indenting.
  filetype plugin indent on

  " Put these in an autocmd group, so that we can delete them easily.
  augroup vimrcEx
  au!

  " Set the `filetype` to `text` if is not already set.
  autocmd BufEnter * if &filetype == "" | setlocal ft=text | endif

  " For all text files set 'textwidth' to 78 characters.
  autocmd FileType text setlocal textwidth=78

  " When editing a file, always jump to the last known cursor position.
  " Don't do it when the position is invalid or when inside an event handler
  " (happens when dropping a file on gvim).
  " Also don't do it when the mark is in the first line, that is the default
  " position when opening a file.
  autocmd BufReadPost *
    \ if line("'\"") > 1 && line("'\"") <= line("$") |
    \   exe "normal! g`\"" |
    \ endif

  augroup END

else

  set autoindent " always set autoindenting on

endif " has("autocmd")

" allow backspacing over everything in insert mode
set backspace=indent,eol,start

" In many terminal emulators the mouse works just fine, thus enable it.
if has('mouse')
  set mouse=a
endif

" Convenient command to see the difference between the current buffer and the
" file it was loaded from, thus the changes you made.
" Only define it when not defined already.
if !exists(":DiffOrig")
  command DiffOrig vert new | set bt=nofile | r ++edit # | 0d_ | diffthis
  \ | wincmd p | diffthis
endif

if &diff
  set diffopt=filler,context:1000000
endif

set nobackup

" file encoding
set fileencodings=utf-8,ucs-bom,gb18030,gbk,gb2312,cp936;
set termencoding=utf-8
set encoding=utf-8

" set the number of spaces for an indent level to 4
" and also map tab to spaces
set tabstop=4
set expandtab
set shiftwidth=4
set softtabstop=4

" make <Left><Right> available to get across EOL
set whichwrap+=<,>

let g:tex_flavor="latex"

" =======================================================================
" }}}


" Appearance {{{
" =======================================================================

" Switch syntax highlighting on, when the terminal has colors
" Also switch on highlighting the last used search pattern.
if &t_Co > 2 || has("gui_running")
  syntax on
  set hlsearch
  set incsearch " do incremental searching
  colorscheme gruvbox
  set background=dark
  set cursorline
  highlight Normal ctermbg=NONE
  highlight NonText ctermbg=NONE
endif

set ruler " show the cursor position all the time
set showcmd " display incomplete commands

set number
" if exists('&relativenumber')
"   set relativenumber
" endif

set laststatus=2
set smartindent
set autoindent

set wrap linebreak textwidth=0
if exists('&colorcolumn')
  set colorcolumn=80
endif

let &t_Co=256

set noshowmode

" =======================================================================
" }}}


" Key Mapping {{{
" =======================================================================

" Don't use Ex mode, use Q for formatting
map Q gq

" CTRL-U in insert mode deletes a lot.  Use CTRL-G u to first break undo,
" so that you can undo CTRL-U after inserting a line break.
inoremap <C-U> <C-G>u<C-U>

" Map leader key to <SPACE>
nnoremap <SPACE> <Nop>
let mapleader="\<SPACE>"
let maplocalleader=","

map ; :
inoremap jk <ESC>
inoremap kj <ESC>

nnoremap <expr> j v:count ? 'j' : 'gjzz'
nnoremap <expr> k v:count ? 'k' : 'gkzz'

" search selected text in visual mode
vnoremap // y/\V<C-r>=escape(@",'/\')<CR><CR>

" <Ctrl-l> redraws the screen and REMOVES ANY SEARCH HIGHLIGHTING
nnoremap <silent> <C-l> :nohl<CR><C-l>

" =======================================================================
" }}}


" Plugins (using 'junegunn/vim-plug') {{{
" =======================================================================
if has('win32')
  call plug#begin('~\vimfiles\plugged')
else
  call plug#begin('~/.vim/plugged')
endif

" Appearance
" =======================================================================
" hightlight brackets
Plug 'luochen1990/rainbow'
" status line
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
" =======================================================================


" Editor Enhancement
" =======================================================================
Plug 'dhruvasagar/vim-table-mode'
Plug 'easymotion/vim-easymotion'
Plug 'lukelike/auto-pairs'
Plug 'lukelike/vim-fcitx-switch'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-surround'
" =======================================================================


" Additional Functionalities
" =======================================================================
Plug 'junegunn/fzf', { 'do': './install --all' }
Plug 'junegunn/fzf.vim'
Plug 'majutsushi/tagbar'

" file tree
Plug 'scrooloose/nerdtree', { 'on': 'NERDTreeToggle' }

" snippets
Plug 'SirVer/ultisnips'

" send text from vim buffer to tmux buffer
Plug 'lukelike/tslime.vim'

Plug 'skywind3000/asyncrun.vim'
" =======================================================================


" Languages Plugins
" =======================================================================
" Go
Plug 'fatih/vim-go', { 'do': ':GoUpdateBinaries' }
" LaTeX
Plug 'lervag/vimtex', { 'for': 'tex' }
" Markdown
Plug 'gabrielelana/vim-markdown'
" Python
Plug 'davidhalter/jedi-vim', { 'for': 'python' }
Plug 'Vimjas/vim-python-pep8-indent', { 'for': 'python' }
" Rust
Plug 'rust-lang/rust.vim', { 'for': 'rust' }
" =======================================================================
call plug#end()
" =======================================================================
" }}}


" Plugin Settings {{{
" =======================================================================
" luochen1990/rainbow
let g:rainbow_active = 1
let g:rainbow_conf = {
  \	'guifgs': ['royalblue3', 'darkorange3', 'seagreen3', 'firebrick'],
  \	'ctermfgs': ['lightblue', 'lightyellow', 'lightcyan', 'lightmagenta'],
  \	'operators': '_,_',
  \	'parentheses': ['start=/(/ end=/)/ fold', 'start=/\[/ end=/\]/ fold', 'start=/{/ end=/}/ fold'],
  \	'separately': {
  \   '*': 0,
  \   'scheme': {
  \     'guifgs': ['royalblue3', 'darkorange3', 'seagreen3', 'firebrick', 
  \                'darkorchid3'],
  \   },
  \		'lisp': {
  \	    'guifgs': ['royalblue3', 'darkorange3', 'seagreen3', 'firebrick', 
  \                'darkorchid3'],
  \   },
  \   'html': 0,
  \   'css': 0,
  \ }
  \}

" vim-airline/vim-airline
let g:airline#extensions#tabline#enabled = 0
if !exists('g:airline_symbols')
  let g:airline_symbols = {}
endif
let g:airline_symbols.maxlinenr = ''
let g:airline_theme='wombat'

" scrooloose/nerdtree
nmap <c-b> :NERDTreeToggle<CR>
imap <c-b> <ESC>:NERDTreeToggle<CR>
let NERDTreeNodeDelimiter="\t"

" skywind3000/asyncrun.vim
let g:asyncrun_mode=0
let g:asyncrun_open=8
noremap <C-j> :call asyncrun#quickfix_toggle(8)<cr>
noremap <leader>r :AsyncRun<SPACE>

" lukelike/auto-pairs
let g:AutoPairs={'(':')', '[':']', '{':'}'}

" davidhalter/jedi-vim
let g:jedi#rename_command="<leader>rn"
let g:jedi#popup_on_dot=0
let g:jedi#show_call_signatures=2
set completeopt-=preview

" junegunn/fzf.vim
nmap <leader>p :Buffers<CR>
nmap <leader>o :Files<CR>

" majutsushi/tagbar
let g:airline#extensions#tagbar#enabled = 0
nmap <leader>tb :TagbarToggle<CR>

" lervag/vimtex
let g:vimtex_compiler_latexmk = {
      \ 'build_dir': './tmp'
      \ }
let g:vimtex_compiler_callback_hooks = ['CopyFromTemp']
function! CopyFromTemp(status)
  if exists('b:vimtex.root')
    if has('win32')
      let l:srcname = b:vimtex.root . '\tmp\' . b:vimtex.name . '.pdf'
      let l:desname = b:vimtex.root . '\' . b:vimtex.name . '.pdf'
      silent exe '!start /B copy "' . l:srcname . '" "' . l:desname . '"'
    else
      let l:srcname = b:vimtex.root . '/tmp/' . b:vimtex.name . '.pdf'
      let l:desname = b:vimtex.root . '/' . b:vimtex.name . '.pdf'
      silent exe '!cp "' . l:srcname . '" "' . l:desname . '"'
    endif
  endif
endfunction

let g:vimtex_quickfix_mode = 0
if has('win32')
  let g:vimtex_view_general_viewer = 'SumatraPDF'
  let g:vimtex_view_general_options
      \ = '-reuse-instance -forward-search @tex @line @pdf'
      \ . ' -inverse-search "gvim --servername ' . v:servername
      \ . ' --remote-send \"^<C-\^>^<C-n^>'
      \ . ':drop \%f^<CR^>:\%l^<CR^>:normal\! zzzv^<CR^>'
      \ . ':execute ''drop '' . fnameescape(''\%f'')^<CR^>'
      \ . ':\%l^<CR^>:normal\! zzzv^<CR^>'
      \ . ':call remote_foreground('''.v:servername.''')^<CR^>^<CR^>\""'
  let g:vimtex_view_general_options_latexmk = '-reuse-instance'
else
  let g:vimtex_view_method = 'zathura'
endif

" dhruvasagar/vim-table-mode
let g:table_mode_corner = '|'

" gabrielelana/vim-markdown
let g:markdown_enable_spell_checking = 0
let g:markdown_mapping_switch_status = "<LocalLeader>s"


" =======================================================================
" }}}


" settings for GVim and Windows {{{
if has("gui_running")
  let $LANG='en_US'
  set langmenu=en_US
  source $VIMRUNTIME/delmenu.vim
  source $VIMRUNTIME/menu.vim
  set guioptions-=m
  set guioptions-=T
  set guifont=Consolas:h11

  set lines=32
  set columns=85
  set clipboard=unnamed,unnamedplus
  " disable IME when entering Normal mode
  set noimdisable
  " support for formating CJK characters
  set formatoptions+=mB

  nmap <leader>sc <ESC>:setlocal spell spelllang=en_us<CR>
  nmap <leader>ss <ESC>:setlocal nospell<CR>
  vmap <leader>c "+y
  nmap <leader>v "+p

  nnoremap <M-Space> :simalt ~<cr>
  inoremap <M-Space> <esc>:simalt ~<cr>
endif

if has("win32")
  set pythondll=C:\Applications\Miniconda3\envs\py27_32\python27.dll
  set pythonhome=C:\Applications\Miniconda3\envs\py27_32
  set noswapfile
endif
" }}}


" Load the settings for local machine
if !empty(glob("$HOME/_vimrc.local"))
  source $HOME/_vimrc.local
endif
if !empty(glob("$HOME/.vimrc.local"))
  source $HOME/.vimrc.local
endif

" enable folder specific .vimrc files
set exrc
set secure

set nofoldenable
set foldlevel=100

" vim:set foldmethod=marker foldlevel=0 sts=2 sw=2 ts=2 expandtab nomodeline:

