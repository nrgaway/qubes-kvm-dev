" VIMRC
" =====
"
"
" COMMAND HELP
" ============
" vip: visial select paragraph
" v:   visual mode used to select text
" gq:  rewrap text block
"
"
" Spelling Navigation:
"      :set spell : Enable spell checking, select next word.
"                   <F7>
"    :set nospell : Disable spell checking.
"                   <CONTROL>+<F7>
" :set spelllang= : Toggle between spelling languages defined in
"                   'g:spellLanguages'.
"                   <CONTROL>+<SHIFT>+<F7>
"              ]s : Move to next misspelled word.
"                   <F7>
"              [s : Move to previous misspelled word.
"                   <SHIFT>+<F7>
"              z= : Word suggestion.
"                   <CONTROL>+<SPACE>
"              zg : Add word to dictionary (good word).
"
" Word Completion:
" <CTRL>+<N> or <CTRL>+<P>
"
" textwidth (or tw):
"     controls the wrap width you would like to use. Use :se tw=72 to set
"     the wrap width; by default it's unset and thus disables line-wrapping.
"     If this value is set, you're entirely at the whimsy of the below 
"     formatoptions, which is often filetype sensitive.
"
" formatoptions (or fo):
"     Controls whether or not automatic text wrapping is enabled, depending on
"     whether or not the t flag is set. Toggle the flag on with :set fo+=t,
"     and toggle it off with :set fo-=t. There are also a number of auxiliary
"     format options, but they're not as important.  wrapmargin (or wm):
"     controls when to wrap based on terminal size; I generally find using
"     this to be a bad idea.
"
" Example wrapping configurations:
"
"     No automatic wrapping, rewrapping will wrap to 72
"         textwidth=72 formatoptions=cq wrapmargin=0
"
"     No automatic wrapping, rewrapping will wrap to 72
"         textwidth=0 formatoptions=cqt wrapmargin=0
"
"     No automatic wrapping, rewrapping will wrap to 80
"         textwidth=0 formatoptions=cq wrapmargin=0
"
"     Automatic wrapping at a 5 col right margin
"         textwidth=0 formatoptions=cqt wrapmargin=5
"
"     Automatic wrapping at col 72
"         textwidth=72 formatoptions=cqt wrapmargin=0
"
"
" REFERENCES
" ==========
"
" Really good articles on how to use vim
" https://robots.thoughtbot.com/tags/vim
"
" A set of vim, zsh, git, and tmux configuration files.
" https://thoughtbot.com/open-source
"
" Displaying the current Vim environment
" https://vim.fandom.com/wiki/Displaying_the_current_Vim_environment

" ==============================================================================
" General Options
" ==============================================================================
set modeline            " Use file’s modeline instead of vimrc configuration.
set viminfo=

"set mouse=v 			"   N   N    Y    Y   Y    Y
"set mouse=c 			"   N   N    Y    Y   Y    Y
"set mouse=nvi			"   Y   Y    N    N   N    N
"set mouse=ni			"   Y   Y    N    N   N    N
"set mouse=r 			"   N   N    Y    Y   Y    Y
"set mouse=a 			"   Y   Y    N    N   N    N
                        " Position | Select | Copy       - CLIPBOARD COMMENT OUT
                        "  Nor Ins |Nor  Ins|Nor  Ins
"set mouse=n 			"   Y   N    N    Y   N    Y
"set mouse=nv			"   Y   N    N    Y   N    Y
"set mouse=i 			"   N   Y    Y    N   Y    N
"
"set mouse=vi			"   N   Y    N    Y   N    Y  COMPLETE CONTROL in INS

"set mouse=nir			"   ?   ?    ?    ?   ?    ?
"set mouse=nirc			"   ?   ?    ?    ?   ?    ?
"set mouse=nic			"   ?   ?    ?    ?   ?    ?
"set mouse=nvi			"   ?   ?    ?    ?   ?    ?

set mouse=v             " NOTE: Use <SHIFT> key when selecting text to enable
                        " ability to use context menu for copy, etc.
                        " Enable the use of the mouse.  Works for most terminals (xterm, MS-DOS, 
                        " Win32 win32-mouse, QNX pterm, *BSD console with sysmouse and Linux     
                        " console with gpm).  For using the mouse in the GUI, see gui-mouse.     
                        " The mouse can be enabled for different modes:                          
                        "         n       Normal mode and Terminal modes                         
                        "         v       Visual mode                                            
                        "         i       Insert mode                                            
                        "         c       Command-line mode                                      
                        "         h       all previous modes when editing a help file            
                        "         a       all previous modes                                     
                        "         r       for hit-enter and more-prompt prompt                   
                        " Normally you would enable the mouse in all five modes with:            
                        "         :set mouse=a                                                   
                        " If your terminal can't overrule the mouse events going to the           
                        " application, use:                                                      
                        "         :set mouse=nvi                                                 
                        " The you can press ":", select text for the system, and press Esc to go  
                        " back to Vim using the mouse events.                                    
                        " In defaults.vim "nvi" is used if the 'term' option is not matching     
                        " xterm". 

""set clipboard=unnamed " Allows use of <y> key to yank mouse selection. (Seems
                        " like not required for yanking in visual mode.

" Leader
let mapleader = " "

" ==============================================================================
" Plugin Manager (https://github.com/junegunn/vim-plug)
" ==============================================================================
" :PlugInstall [name ...] [#threads]  Install plugins.
" :PlugUpdate [name ...] [#threads]   Install or update plugins.
" :PlugClean[!]                       Remove unlisted plugins (bang version will
"                                     clean without prompt).
" :PlugUpgrade                        Upgrade vim-plug itself.
" :PlugStatus                         Check the status of plugins.
" :PlugDiff                           Examine changes from the previous update
"                                     and the pending changes.
" :PlugSnapshot[!] [output path]      Generate script for restoring the current
"                                     snapshot of the plugins.
function! PlugLoaded(name)
    " vim-plug specific plugin loaded test.
    return (
        \ has_key(g:plugs, a:name) &&
        \ isdirectory(g:plugs[a:name].dir) &&
        \ stridx(&rtp, split(g:plugs[a:name].dir, '/$')[0]) >= 0)
endfunction

filetype plugin on
silent! call plug#begin('~/.vim/plugged')

" VIM Defaults: Sensible
" sensible.vim: Defaults everyone can agree on.
" https://github.com/tpope/vim-sensible
Plug 'tpope/vim-sensible'

" Git Wrapper: Fugitive
" A Git wrapper so awesome, it should be illegal.
" https://github.com/tpope/vim-fugitive
Plug 'tpope/vim-fugitive'

" Status Bar: Airline
" Lean & mean status/tabline for vim that's light as air.
" https://github.com/vim-airline/vim-airline
""Plug 'vim-airline/vim-airline'

" Status Bar: Lightline
" A light and configurable statusline/tabline plugin for Vim.
" https://github.com/itchyny/lightline.vim
Plug 'itchyny/lightline.vim'

" --- COLOR SCHEMES ------------------------------------------------------------
" Color Scheme: Github
" A Vim colorscheme based on Github's syntax highlighting as of 2018.
" https://github.com/cormacrelf/vim-colors-github
Plug 'cormacrelf/vim-colors-github'

" Color Scheme: Seoul256
" Low-contrast Vim color scheme based on Seoul Colors.
" https://github.com/junegunn/seoul256.vim
""Plug 'junegunn/seoul256.vim'

" --- OTHER --------------------------------------------------------------------
" Pencil Writing Tools:
"Rethinking Vim as a tool for writing
"https://github.com/reedes/vim-pencil
Plug 'reedes/vim-pencil'

" Smooth Scrolling:  Comfortable Motion
" Brings physics-based smooth scrolling to the Vim world!
" https://github.com/yuttie/comfortable-motion.vim
Plug 'yuttie/comfortable-motion.vim'

" Supertab:
" Perform all your vim insert mode completions with Tab
" https://github.com/ervandew/supertab
"Plug 'ervandew/supertab'

call plug#end()

" ==============================================================================
" Plugin Configurations
" ==============================================================================
" ------------------------------------------------------------------------------
" Vim Sensible: 'tpope/vim-sensible'
" ------------------------------------------------------------------------------
runtime! plugin/sensible.vim

" ------------------------------------------------------------------------------
" Fugitive Git Wrapper: 'tpope/vim-fugitive'
" ------------------------------------------------------------------------------
" Reset foldmethod back to manual.
""set foldmethod=manual

" ------------------------------------------------------------------------------
" Lightlime Status Bar: 'itchyny/lightline.vim'
" ------------------------------------------------------------------------------
set noshowmode

function GetSpellLanguage()
    ""if &spell | return &spelllang | else | return 'nospell' | endif
    if !empty(&spelllang) | return &spelllang | else | return 'nospell' | endif
endfunction

let g:lightline = {
    \ 'colorscheme': 'seoul256',
    \ 'active': {
    \   'left': [ [ 'mode', 'paste' ],
    \             [ 'gitbranch', 'readonly', 'filename', 'modified' ] ],
    \   'right': [ [ 'lineinfo' ],
    \            [ 'percent' ],
    \            [ 'fileformat', 'fileencoding', 'filetype', 'spelllanguage' ] ]
    \ },
    \ 'component_function': {
    \   'gitbranch': 'fugitive#head',
    \   'spelllanguage': 'GetSpellLanguage'
    \ },
    \ }

" ------------------------------------------------------------------------------
" Color Schemes:
" ------------------------------------------------------------------------------
if PlugLoaded('vim-colors-github')
    " Github Color Scheme: 'cormacrelf/vim-colors-github'

    " Use a slightly darker background, like GitHub inline code blocks.
    ""let g:github_colors_soft = 1
    colorscheme github
    ""let g:lightline = { 'colorscheme': 'github' }

    " Replace undercurl formatting with double underline.
    if v:progname == 'vim'
        set t_Cs=[21m
        set t_Ce=[24m
    endif
    ""highlight SpellBad term=underline cterm=underline ctermfg=167 gui=undercurl guifg=#d73a49 guisp=#d73a49
    ""highlight SpellCap cterm=undercurl guisp=Blue guibg=Black

elseif PlugLoaded('seoul256.vim')
    " Seoul256 Color Scheme: 'junegunn/seoul256.vim'

    " DARK - Unified color scheme (default: dark)
    "   range:   233 (darkest) ~ 239 (lightest)
    "   default: 237
    ""let g:seoul256_background = 236

    " LIGHT - seoul256 (light)
    "   range:   252 (darkest) ~ 256 (lightest)
    "   default: 253
    let g:seoul256_background = 256

    colorscheme seoul256
endif

" ==============================================================================
" Indention Options:
" ==============================================================================
set autoindent          " New lines inherit the indentation of previous lines.
filetype indent on      " Enable indentation rules that are file-type specific.

" Softtabs, 4 spaces
set expandtab           " Convert tabs to spaces.
set tabstop=4           " Indent using four spaces.
set shiftround          " When shifting lines, round the indentation to the
                        " nearest multiple of “shiftwidth.”
set shiftwidth=4        " When shifting, indent using four spaces.
set smarttab            " Insert “tabstop” number of spaces when the “tab” key
                        " is pressed.  affects how <TAB> key presses are
                        " interpreted depending on where the cursor is. If
                        " 'smarttab' is on, a <TAB> key inserts indentation
                        " according to 'shiftwidth' at the beginning of the
                        " line, whereas 'tabstop' and 'softtabstop' are used
                        " elsewhere. There is seldom any need to set this
                        " option, unless it is necessary to use hard TAB
                        " characters in body text or code.
""set softtabstop       " Affects what happens when you press the <TAB> or <BS>
                        " keys. Its default value is the same as the value of
                        " 'tabstop', but when using indentation without hard
                        " tabs or mixed indentation, you want to set it to the
                        " same value as 'shiftwidth'. If 'expandtab' is unset,
                        " and 'tabstop' is different from 'softtabstop', the
                        " <TAB> key will minimize the amount of spaces inserted
                        " by using multiples of TAB characters. For instance, if
                        " 'tabstop' is 8, and the amount of consecutive space
                        " inserted is 20, two TAB characters and four spaces
                        " will be used. 

" ==============================================================================
" User Interface Options:
" ==============================================================================
set laststatus=2        " Always display the status bar.
set ruler               " Always show cursor position.
set title               " Set the window’s title, reflecting the file currently
                        " being edited.

" Make it obvious where 80 characters is.
set textwidth=80
set colorcolumn=+1

" Display extra whitespace
set list listchars=tab:»·,trail:·,nbsp:·

" Use one space, not two, after punctuation.
""set nojoinspaces

""set cursorline        " Highlight the line currently under cursor.
""set number            " Show line numbers on the sidebar.
""set numberwidth=5     " Minimal number of columns to use for line number.
""set relativenumber    " Show line number on the current line and relative
                        " numbers on all other lines.

" When editing a file, always jump to the last known cursor position.
" Don't do it for commit messages, when the position is invalid, or when inside
" an event handler (happens when dropping a file on gvim).
augroup vimrc_interface_cursor_position
    au!
    autocmd BufReadPost *
        \ if &ft != 'gitcommit' && line("'\"") > 0 && line("'\"") <= line("$") |
        \   exe "normal g`\"" |
        \ endif
augroup END

"-------------------------------------------------------------------------------
" Tab Completion:
set wildmenu            " Display command line’s tab complete options as a menu.
set wildmode=list:longest,list:full

" Insert tab at beginning of line, and use completion if not at beginning.
function! InsertTabWrapper()
    let col = col('.') - 1
    if !col || getline('.')[col - 1] !~ '\k'
        return "\<tab>"
    else
        return "\<c-p>"
    endif
endfunction
inoremap <Tab> <c-r>=InsertTabWrapper()<cr>
inoremap <S-Tab> <c-n>


" ==============================================================================
" Text Rendering Options:
" ==============================================================================
set display+=lastline   " Always try to show a paragraph’s last line.
set scrolloff=1         " The number of screen lines to keep above and below the
                        " cursor.
set sidescrolloff=5     " The number of screen columns to keep to the left and
                        " right of the cursor.
""set encoding=utf-8    " Use an encoding that supports unicode.
""set linebreak         " Avoid wrapping a line in the middle of a word.
""set wrap              " Enable line wrapping.

" Code folding options
set nofoldenable        " Disable folding by default.
""set foldmethod=manual " Fold based on indention levels.
""set foldnestmax=3     " Only fold up to three nested levels.

" Switch syntax highlighting on, when the terminal has colors
" and switch on highlighting the last used search pattern.
"'&t_Co' is number of colors the terminal supports
if (&t_Co > 2 || has("gui_running")) && !exists("syntax_on")
    syntax enable
endif

" Treat <li> and <p> tags like the block tags they are.
let g:html_indent_tags = 'li\|p'

" Enable AnsiEsc to display text with ANSI sequences
augroup vimrc_ansi
    au!
    autocmd BufNewFile,BufRead *.ansi AnsiEsc
augroup END

if has("autocmd")
    " --------------------------------------------------------------------------
    " Set custom syntax highlighting for specific file types.
    " --------------------------------------------------------------------------
    augroup vimrc_syntax_highlight
        au!
        autocmd BufRead,BufNewFile Appraisals set filetype=ruby
        autocmd BufRead,BufNewFile *.md set filetype=markdown
        autocmd BufRead,BufNewFile .{jscs,jshint,eslint}rc set filetype=json

        " Setting for .md files.
        autocmd BufRead,BufNewFile *.md setlocal textwidth=80
    augroup END

    " --------------------------------------------------------------------------
    " YAML BlockMappingKey display format.
    " --------------------------------------------------------------------------
    augroup vimrc_syntax_yaml
        au!
        autocmd FileType yaml execute
            \'syn match yamlBlockMappingKey /^\s*\zs.*\ze\s*:\%(\s\|$\)/'
    augroup END

    " --------------------------------------------------------------------------
    " COMMENTS in italics
    " --------------------------------------------------------------------------
    augroup vimrc_syntax_comment
        au!
        autocmd FileType * highlight Comment term=italic cterm=italic gui=italic
    augroup END
    
    " --------------------------------------------------------------------------
    " COMMENTS - Special
    " --------------------------------------------------------------------------
    augroup vimrc_syntax_comment
        au!
        autocmd BufEnter *.py syntax match specialComment /\v(##.*)/ containedin=.*Comment
        autocmd Syntax sh syntax match specialComment /\v(##.*)/ containedin=.*Comment
        autocmd Syntax vim syntax match specialComment /\v("".*)/ containedin=.*Comment
    augroup END
    highlight specialComment ctermfg=250 guifg=#babbbc

    " --------------------------------------------------------------------------
    " TODO highlighting
    " --------------------------------------------------------------------------
    augroup vimrc_syntax_todo
        au!
        autocmd Syntax * syn match allTodo 
            \ /\v<(FIXME|NOTES|NOTE|TODO|XXX|WIP|TEMP|DEBUG|REMOVE|TEST)\ze:/
            \ containedin=.*Comment,vimCommentTitle
        autocmd bufread * highlight def link allTodo Todo
    augroup END
    highlight def link allTodo Todo

    " --------------------------------------------------------------------------
    " VAULT textfile
    " --------------------------------------------------------------------------
    augroup vimrc_textfile " For vault
        au!
        autocmd BufRead,BufNewFile *.txt set scrolloff=0
        autocmd BufRead,BufNewFile *.txt set mouse=r
    augroup END
endif

" ==============================================================================
" Spelling:
" ==============================================================================
if filereadable(expand("~/.vim/spell.vim"))
    set spelllang=en_us,en_ca

    " Set spellfile to location that is guaranteed to exist, can be symlinked to
    " Dropbox or kept in Git and managed outside.
    set spellfile=~/.vim/spell/en.utf-8.add

    " Enable spelling by default for specific file types.
    augroup vimrc_spell
        au!
        autocmd FileType markdown setlocal spell
        autocmd FileType gitcommit setlocal spell
    augroup END

    " Auto-complete with dictionary words when spell check is on.
    set complete+=kspell

    " -------------------------------------------------------------------------
    " Spell Plugin Options:
    " -------------------------------------------------------------------------
    let g:spellLanguages=["en_ca","en_us"]
    source ~/.vim/spell.vim
endif

" ==============================================================================
" Search Options:
" ==============================================================================
set incsearch           " Incremental search that shows partial matches.
set hlsearch            " Enable search highlighting.
""set ignorecase        " Ignore case when searching.
""set smartcase         " Automatically switch search to case-sensitive when
                        " search query contains an uppercase letter.

" ==============================================================================
" Performance Options:
" ==============================================================================
set complete-=i         " Limit the files searched for auto-completes.
""set lazyredraw        " Don’t update screen during macro and script execution.

" ==============================================================================
" Miscellaneous Options:
" ==============================================================================
set autoread            " Automatically re-read files if unmodified inside Vim.
set formatoptions+=j    " Delete comment characters when joining lines.
set history=1000        " Increase the undo limit.
set nrformats-=octal    " Interpret octal as decimal when incrementing numbers.
""set noswapfile        " Disable swap files.

" The shell used to execute commands.
set shell=/usr/bin/env\ bash 

" Allow backspacing over indention, line breaks and insertion start.
set backspace=indent,eol,start

" <SPACE> Switch between the last two files.
nnoremap <leader><leader> <c-^>

" <F2> Toggle paste mode on/off.
set pastetoggle=<F2>

" <F12> Tidy shortcut
map <F12> :%!tidy -q --tidy-mark 0 2>/dev/null<CR>

" Ignore files matching these patterns when opening files based on a glob
" pattern.
""set wildignore+=.pyc,.swp  

" vim:set ft=vim et sw=4 ts=4 sts=4:
