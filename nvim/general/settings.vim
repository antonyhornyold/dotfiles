" Not needed?
set nocompatible
filetype plugin on
filetype indent on

syntax enable
set encoding=utf-8
set fileencoding=utf-8
scriptencoding utf-8

let mapleader =' '

" make all file-related tasks search down subfolders
set path+=**

" ----- GENERAL CONFIG -----

set number
set relativenumber
set numberwidth=5

set mouse=a

" make it obvs where 80 cols are...
set textwidth=80
set colorcolumn=+1
set cursorline

" wrap lines
set wrap linebreak
set nojoinspaces

" allow backspace in insert mode
set backspace=indent,eol,start

" disable all error bells
set noerrorbells

" do any of the following work?
set autowrite
set autoread
" check for filechanges every 4 seconds
au CursorHold * checktime

" make nvim ast sanely allow buffers in background
set hidden

set nostartofline
set scrolloff=5

" no intro message
set shortmess=atI
" don;t pass messages to |ins-completion-menu|
set shortmess+=c

" opem mew splits sensibly
set splitbelow
set splitright

set timeoutlen=1000 ttimeoutlen=0
" longer updatetime (default is 4000 4ms) leads to noticeable delays
set updatetime=300

" ----- COSMETICS -----

" nvim supports mode-dependent cursor shape built-in
" set guicursor=n-v-c:block,i-ci-ve:ver25,r-cr:hor20,o:hor50
" set gcr=a:blinkon0

" set invisible chars = `:help listchars` to see options
set list lcs=tab:▸\ ,trail:·,nbsp:_
set showbreak=↪

" use the *real* full-height vertical bar to make solid lines
set fillchars+=vert:│
" airline covers this
set noshowmode
" Show the cursor position
" set ruler
set noruler
set laststatus=0
" Show the (partial) command as it’s being typed
set showcmd
" Give more space for displaying messages.
set cmdheight=1
" Always show the signcolumn, otherwise it would shift the text each time
" diagnostics appear/become resolved.
if has("patch-8.1.1564")
  " Recently vim can merge signcolumn and number column into one
  set signcolumn=number
else
  set signcolumn=yes
endif

" ------ SET NO SWAPS / BACKUPS ------

set nobackup
set nowritebackup
set noswapfile

" ------ SET PERSISTENT UNDO ------

set history=1000
" Keep undo history across sessions, by storing in file.
" Only works all the time.
if has('persistent_undo') && isdirectory(expand('$HOME').'/.config/nvim/undo')
  silent !mkdir $HOME/.config/nvim/undo > /dev/null 2>&1
  set undodir=$HOME/.config/nvim/undo
  set undofile
endif

" ------ SET INDENTATION ------

set autoindent
set smartindent
set smarttab
" indent using spaces
set expandtab
" make tabs 2 spaces wide
set tabstop=2
set softtabstop=2
set shiftwidth=2
set shiftround

" Auto indent pasted text
nnoremap p p=`]<C-o>
nnoremap P P=`]<C-o>

" ------ SET SEARCH PARAMS ------

set incsearch
set hlsearch
set ignorecase
" be case-insensitive unless I use uppercase
set smartcase
" Add the g flag to search/replace by default
set gdefault

set wildmenu
set wildmode=longest:full,full
set wildignore=*.env
set wildignore+=DS_Store
set wildignore+=*.pyc
set wildignore+=__pycache__
set wildignore+=*.swp
set wildignore+=*.bak

" nvim - always use system clipboard (via pbcopy)
set clipboard+=unnamedplus

" ------ SET FOLDS ------

set nofoldenable

" ------ SET COMMENTS ------

" stop putting comments when 'newline' from commented line
"http://vim.wikia.com/wiki/Disable_automatic_comment_insertion
autocmd FileType * setlocal formatoptions-=c formatoptions-=r formatoptions-=o

