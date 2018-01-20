" set re=1
set nocompatible               " be iMproved

"  ---------------------------------------------------------------------------
"  Plugins
"  ---------------------------------------------------------------------------

" Specify a directory for plugins (for Neovim: ~/.local/share/nvim/plugged)
call plug#begin('~/.config/nvim/plugged')

" rust
Plug 'autozimu/LanguageClient-neovim', {
    \ 'branch': 'next',
    \ 'do': 'bash install.sh',
    \ }

Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins', 'for': 'rust' }
Plug 'rust-lang/rust.vim', { 'for': 'rust' }
Plug 'cespare/vim-toml'

Plug 'tpope/vim-rails', { 'for': 'ruby' }
Plug 'SirVer/ultisnips'
Plug 'bling/vim-airline'
Plug 'ekalinin/Dockerfile.vim', { 'for': 'Dockerfile' }
Plug 'godlygeek/tabular'
if has('macunix')
  Plug 'junegunn/fzf'
elseif has('unix')
  Plug 'saks/gpicker.vim'
endif
Plug 'saks/vim-snippets'
" Plug 'tomtom/quickfixsigns_vim'
Plug 'mhinz/vim-signify'
Plug 'tomtom/tcomment_vim'
Plug 'tpope/vim-endwise'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-unimpaired'
Plug 'AndrewRadev/splitjoin.vim'
Plug 'linkedin/dustjs'

call plug#end()

"  ---------------------------------------------------------------------------
"  General
"  ---------------------------------------------------------------------------

filetype plugin indent on
let mapleader = ","
let g:mapleader = ","
" set modelines=0
syntax enable

" "russian langmap setup
" " set langmap=ФИСВУАПРШОЛДЬТЩЗЙКЫЕГМЦЧНЯЖ;ABCDEFGHIJKLMNOPQRSTUVWXYZ:,фисвуапршолдьтщзйкыегмцчня;abcdefghijklmnopqrstuvwxyz

" Tabboo (https://github.com/gcmt/taboo.vim#basic-options)
let g:taboo_tab_format = "[ %f %N ]%m"

" TOhtml setup:
let g:html_use_css = 0
let html_number_lines = 1

"  ---------------------------------------------------------------------------
"  UI
"  ---------------------------------------------------------------------------

" don't show completion preview window
set completeopt-=preview

set termguicolors " true colors in the terminal
set title
set encoding=utf-8
set scrolloff=3
set autoindent
set smartindent
set showmode
set showcmd
set hidden
set wildmenu
set wildmode=list:longest
set splitright

" yank to system clipboard
set clipboard+=unnamedplus

" Show $ at end of line and trailing space as ~
set lcs=tab:▸\ ,eol:¬,trail:.,extends:>,precedes:<

set novisualbell  " No blinking .
set noerrorbells  " No noise.
set laststatus=2  " Always show status line.

set cursorline
set ttyfast
set ruler
set backspace=indent,eol,start
set number
set numberwidth=5
set undofile
set timeoutlen=100  " Time to wait after ESC (default causes an annoying delay)

"  ---------------------------------------------------------------------------
"  Backups
"  ---------------------------------------------------------------------------
set history=1000
set swapfile
set backupdir=/tmp
set undodir=~/.vim/.tmp,~/tmp,~/.tmp,/tmp

"  ---------------------------------------------------------------------------
"  Text Formatting
"  ---------------------------------------------------------------------------

set tabstop=2
set shiftwidth=2
set softtabstop=2
set expandtab

set wrap
set textwidth=99
set formatoptions=n
set colorcolumn=100

"  ---------------------------------------------------------------------------
"  Searching / moving
"  ---------------------------------------------------------------------------

set ignorecase

" ignore folllowing files
set wildignore+=*.bak,*~,*.tmp,*.backup,*swp,*.o,*.obj,.git,*.rbc,*.png,*.xpi,*.swf,*.woff,*.eot,*.svg,*.ttf,*.otf

set smartcase
set gdefault
set incsearch
set showmatch
set hlsearch
set mat=5  " Bracket blinking.

"  ---------------------------------------------------------------------------
"  Some functions used in this config
"  ---------------------------------------------------------------------------
" Strip trailing whitespace
function! <SID>StripTrailingWhitespaces()
  " Preparation: save last search, and cursor position.
  let _s=@/
  let l = line(".")
  let c = col(".")
  " Do the business:
  %s/\s\+$//e
  " Clean up: restore previous search history, and cursor position
  let @/=_s
  call cursor(l, c)
endfunction

" Only do this part when compiled with support for autocommands
if has("autocmd")
  augroup saksmlz_autocommands
    autocmd!

    " autocmd FileType lua let b:syntastic_lua_luacheck_args = '--filename ' . expand('<afile>:p', 1)
    " Enable file type detection
    filetype on

    au BufWritePre * :call <SID>StripTrailingWhitespaces()

    " remember folding
    " BufWinLeave failed to update view sometimes
    au BufWinLeave,BufLeave * silent! mkview

    " au BufLeave * silent! mkview
    " au BufUnload * silent! mkview
    " au BufUnload * mkview

    au BufWinEnter * silent! loadview

    " scss and coffee files
    au BufNewFile,BufRead *.scss setfiletype css
    au BufNewFile,BufRead *.coffee setfiletype coffee
    au BufNewFile,BufRead *.moon setfiletype moon

    " Thorfile is Ruby
    au BufRead,BufNewFile {Thorfile,Berksfile} set ft=ruby

    " Customisations based on house-style (arbitrary)
    au FileType html,css,ruby,javascript setlocal ts=2 sts=2 sw=2 expandtab
    au FileType c setlocal ts=4 sts=4 sw=4 expandtab
    au FileType lua setlocal tw=79 cc=80
    au FileType python setlocal tw=79 cc=80
    au FileType rust setlocal tw=79 cc=80
    au FileType javascript setlocal ts=4 sts=4 sw=4 expandtab

    " Go
    au FileType go nmap <Leader>dt <Plug>(go-def-tab)

    " au FileType python setlocal ts=4 sts=4 sw=4 expandtab

    " Syntax of these languages is fussy over tabs Vs spaces
    " au FileType make setlocal ts=8 sts=8 sw=8 noexpandtab
    " au FileType yaml setlocal ts=2 sts=2 sw=2 expandtab

    " When vimrc is edited, reload it
    " au! bufwritepost vimrc source ~/.vimrc

    " Treat .rss files as XML
    " au BufNewFile,BufRead *.rss setfiletype xml

    " set filetype for json file to javascript
    " au BufNewFile,BufRead *.json setfiletype javascript

    " Treat .thor files as Ruby
    " au BufNewFile,BufRead *.thor setfiletype ruby

    " Rust
    au FileType rust nmap gd <Plug>(rust-def)
    au FileType rust nmap gs <Plug>(rust-def-split)
    au FileType rust nmap gx <Plug>(rust-def-vertical)
    au FileType rust nmap <leader>gd <Plug>(rust-doc)
  augroup END

endif

"  ---------------------------------------------------------------------------
"  Status Line
"  ---------------------------------------------------------------------------

" RVM status line
" set statusline+=%{rvm#statusline()}

"  ---------------------------------------------------------------------------
"  Mappings
"  ---------------------------------------------------------------------------
"

" saksmlz specific:
" Use jk intead of <esc>
inoremap jk <esc>
vnoremap jk <esc>
tnoremap jk <C-\><C-N>
" Stop using <esc>
inoremap <esc> <nop>
vnoremap <esc> <nop>

" open tag definition (ctags) in new tab instead of new buffer:
" nnoremap <C-\> :SmartOpenTag<CR>

" CTRL+S saves the buffer
nnoremap <C-s> :w<CR>


" Shortcut to rapidly toggle `set list`
nnoremap <leader>l :set list!<CR>

" Shift+Insert will paste from system buffer (Control+C)
cnoremap <S-Insert>		<C-R>+
exe 'inoremap <script> <S-Insert>' paste#paste_cmd['i']



" Text indentation with Alt+Letf/Right and so on
if has('macunix')
  " FIXME
  " nnoremap <M-Left> <<
  " nnoremap <M-Right> >>
  " vmap <M-Left> <gv
  " vmap <M-Right> >gv
  nnoremap ˙ <<
  nnoremap ¬ >>
  vmap ˙ <gv
  vmap ¬ >gv

  " Text movimg with plugin unimpaired.vim
  " Bubble single lines
  nmap ˚ [e
  nmap ∆ ]e
  " nmap <M-Up> [e
  " nmap <M-Down> ]e

  " Bubble multiple lines
  vmap ˚ [egv
  vmap ∆ ]egv
  " vmap <M-Up> [egv
  " vmap <M-Down> ]egv
elseif has('unix')
  nnoremap <M-Left> <<
  nnoremap <M-Right> >>
  vmap <M-Left> <gv
  vmap <M-Right> >gv
  nnoremap <M-h> <<
  nnoremap <M-l> >>
  vmap <M-h> <gv
  vmap <M-l> >gv

  " Text movimg with plugin unimpaired.vim
  " Bubble single lines
  nmap <M-k> [e
  nmap <M-j> ]e
  nmap <M-Up> [e
  nmap <M-Down> ]e

  " Bubble multiple lines
  vmap <M-k> [egv
  vmap <M-j> ]egv
  vmap <M-Up> [egv
  vmap <M-Down> ]egv
endif

" Clear highlighting
noremap <C-space> :nohl <cr>

" Turn off arrow keys (this might not be a good idea for beginners, but it is
" the best way to ween yourself of arrow keys on to hjkl)
" http://yehudakatz.com/2010/07/29/everyone-who-tried-to-convince-me-to-use-vim-was-wrong/
" "nnoremap <up> <nop>
" "nnoremap <down> <nop>
" "nnoremap <left> <nop>
" "nnoremap <right> <nop>
" "inoremap <up> <nop>
" "inoremap <down> <nop>
" "inoremap <left> <nop>
" "inoremap <right> <nop>

"  ---------------------------------------------------------------------------
"  Plugins
"  ---------------------------------------------------------------------------

" Rust
let g:rustfmt_autosave = 1
" set completefunc=LanguageClient#complete
" set formatexpr=LanguageClient_textDocument_rangeFormatting()

" Deoplete
let g:deoplete#enable_at_startup = 1

if has('macunix')
  let g:fzf_layout = { 'up': '~40%' }
  nnoremap ø :FZF<CR>
  vnoremap ø :FZF<CR>
elseif has('unix')
  " GPicker settings
  " let g:gpicker_open_file_in_tabs = 1
  nnoremap <M-o> :GPickFile<CR>
  vnoremap <M-o> :GPickFile<CR>

  nnoremap <S-M-o> :GPickFileDefault<CR>
  vnoremap <S-M-o> :GPickFileDefault<CR>
endif

let g:quickfixsigns_classes=['qfl', 'vcsdiff', 'breakpoints']

" If you have troubles with special symbls, check out this gist: https://gist.github.com/1634235
" to make it working:
" sudo apt-get install python-pip
" sudo pip install https://github.com/Lokaltog/powerline/tarball/develop

" Airline settings
let g:airline_powerline_fonts = 1
let g:airline_detect_modified = 1
let g:airline_detect_paste = 1
let g:airline_theme = 'dark'

if has('macunix')
  nmap ≤ <Plug>AirlineSelectPrevTab
  nmap ≥ <Plug>AirlineSelectNextTab
  tnoremap ≤ <C-\><C-N><Plug>AirlineSelectPrevTab
  tnoremap ≤ <C-\><C-N><Plug>AirlineSelectNextTab

  nmap ¡ <Plug>AirlineSelectTab1
  nmap ™ <Plug>AirlineSelectTab2
  nmap £ <Plug>AirlineSelectTab3
  nmap ¢ <Plug>AirlineSelectTab4
  nmap ∞ <Plug>AirlineSelectTab5
  nmap § <Plug>AirlineSelectTab6
  nmap ¶ <Plug>AirlineSelectTab7
  nmap • <Plug>AirlineSelectTab8
  nmap ª <Plug>AirlineSelectTab9
elseif has('unix')
  nmap <M-,> <Plug>AirlineSelectPrevTab
  nmap <M-.> <Plug>AirlineSelectNextTab
  tnoremap <M-,> <C-\><C-N><Plug>AirlineSelectPrevTab
  tnoremap <M-.> <C-\><C-N><Plug>AirlineSelectNextTab

  nmap <M-1> <Plug>AirlineSelectTab1
  nmap <M-2> <Plug>AirlineSelectTab2
  nmap <M-3> <Plug>AirlineSelectTab3
  nmap <M-4> <Plug>AirlineSelectTab4
  nmap <M-5> <Plug>AirlineSelectTab5
  nmap <M-6> <Plug>AirlineSelectTab6
  nmap <M-7> <Plug>AirlineSelectTab7
  nmap <M-8> <Plug>AirlineSelectTab8
  nmap <M-9> <Plug>AirlineSelectTab9
endif

let g:airline_extensions = ['branch', 'whitespace', 'tabline']
let g:airline#extensions#tabline#buffer_idx_mode = 1
if exists('g:loaded_syntastic_plugin')
	let g:airline#extensions#syntastic#enabled = 1
endif

" Easy commenting
if has('macunix')
  nnoremap ÷ :TComment<CR>
  vnoremap ÷ :TComment<CR>
elseif has('unix')
  nnoremap <M-/> :TComment<CR>
  vnoremap <M-/> :TComment<CR>
endif

" unite
" Автоматический insert mode
" let g:unite_enable_start_insert = 1

" Отображаем Unite в нижней части экрана
" let g:unite_split_rule = "botright"

" Отключаем замену статус строки
" let g:unite_force_overwrite_statusline = 0

" Размер окна Unite
" let g:unite_winheight = 10

" Красивые стрелочки
" let g:unite_candidate_icon="▷"

" Trigger configuration. Do not use <tab> if you use https://github.com/Valloric/YouCompleteMe.
let g:UltiSnipsExpandTrigger="<tab>"
let g:UltiSnipsJumpForwardTrigger="<tab>"
let g:UltiSnipsJumpBackwardTrigger="<s-tab>"

" If you want :UltiSnipsEdit to split your window.
let g:UltiSnipsEditSplit="vertical"

" Turn off documentation in python_mode
let g:pymode_doc = 0

let g:pymode_options_max_line_length = 99

let g:pymode_rope = 0

let g:pymode_rope_completion = 0
let g:pymode_rope_complete_on_dot = 0

let g:pymode_folding = 0

" Syntastic settings:
let g:syntastic_check_on_open = 1
let g:syntastic_lua_checkers = ["luacheck"]
let g:syntastic_lua_luacheck_args = ""

"  ---------------------------------------------------------------------------
"  GUI
"  ---------------------------------------------------------------------------
vmap <LeftRelease> "*ygv

if has("gui_running")
  set guioptions-=T " no toolbar set guioptions-=m " no menus
  set guioptions-=r " no scrollbar on the right
  set guioptions-=R " no scrollbar on the right
  set guioptions-=l " no scrollbar on the left
  set guioptions-=b " no scrollbar on the bottom
  set guioptions=aiA
  set mouse=v
  set mousehide  " Hide mouse after chars typed
  set mouse=a  " Mouse in all modes
  set guifont=Hack\ 13
  set linespace=1

  " EXTERNAL COPY / PASTE
  " noremap <C-v> "+gP<CR>
  vnoremap <C-c> "+y
endif

if has("nvim")
  " EXTERNAL COPY
  vnoremap <C-c> "+y
endif

colorscheme railscasts

"Invisible character colors
highlight NonText guifg=#4a4a59
highlight SpecialKey guifg=#4a4a59

"  ---------------------------------------------------------------------------
"  Directories
"  ---------------------------------------------------------------------------

" Ctags path (brew install ctags)
let Tlist_Ctags_Cmd = '/usr/bin/ctags'

noremap <Leader>rt :!ctags --languages=ruby -R .<CR><CR>
noremap <Leader>rs :!bundle exec rspec % --no-color -fp<CR>

"  ---------------------------------------------------------------------------
"  Misc
"  ---------------------------------------------------------------------------

" Lang server
" Required for operations modifying multiple buffers like rename.
set hidden

let g:LanguageClient_serverCommands = {
    \ 'rust': ['rustup', 'run', 'nightly-2018-01-14', 'rls'],
    \ }

" Automatically start language servers.
let g:LanguageClient_autoStart = 1

nnoremap <silent> K :call LanguageClient_textDocument_hover()<CR>
nnoremap <silent> gd :call LanguageClient_textDocument_definition()<CR>
nnoremap <silent> <F2> :call LanguageClient_textDocument_rename()<CR>
