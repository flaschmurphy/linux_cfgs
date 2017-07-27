"
" Many lines inspired by http://stevelosh.com/blog/2010/09/coming-home-to-vim/
"

" Pathogen related stuff
filetype off
call pathogen#runtime_append_all_bundles()
filetype plugin indent on

" Don't need to be compatible with old vi
set nocompatible

" Security related. I don't use modelines in anycase.
set modelines=0

" Indent related stuff
filetype plugin indent on
set tabstop=4       " The width of a TAB is set to 4.
                    " Still it is a \t. It is just that
                    " Vim will interpret it to be having
                    " a width of 4.
set shiftwidth=4    " Indents will have a width of 4.
set softtabstop=4   " Sets the number of columns for a TAB.
set expandtab       " Expand TABs to spaces.

" Misc
set encoding=utf-8
set scrolloff=3
set autoindent
set showmode
set showcmd
set hidden
set wildmenu
set wildmode=list:longest
set visualbell
set cursorline
set ttyfast
set ruler
set backspace=indent,eol,start
set laststatus=2

" Show line numbers relative to cursor rather than absolute
set relativenumber

" Enable undo even after a file has been closed
set undofile

" Enable Python/Perl style regex rather than vim builtin
nnoremap / /\v
vnoremap / /\v

" Default to lower case searching unless there's one or more
" upper case letter in the serach string
set ignorecase
set smartcase

" Show results of searches as you type
set incsearch
set showmatch
set hlsearch

" Enable code folding using 'zc', 'za', 'zo'
set foldmethod=indent
set foldnestmax=10
set nofoldenable
set foldlevel=2

" Deal with long lines
set wrap
set textwidth=79
set formatoptions=qrn1
set colorcolumn=85

" Hardcore vim - disable bad key habits
nnoremap <up> <nop>
nnoremap <down> <nop>
nnoremap <left> <nop>
nnoremap <right> <nop>
inoremap <up> <nop>
inoremap <down> <nop>
inoremap <left> <nop>
inoremap <right> <nop>
nnoremap j gj
nnoremap k gk

" Disable F1 key in case you hit it while trying for ESC
inoremap <F1> <ESC>
nnoremap <F1> <ESC>
vnoremap <F1> <ESC>

" Enable auto-save if you alt-tab away from the vim window
au FocusLost * :wa



