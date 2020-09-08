" SPELL.VIM
" =========
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
" Spelling Groups
"     SpellBad: Word not recognized by the spellchecker.
"     SpellCap: Word that should start with a capital.
"   SpellLocal: Word recognized as one that is used in another region.
"    SpellRare: Word recignized as one that is hardly ever used.

" ==============================================================================
" Spelling:
" ==============================================================================
" TODO:
"   - Change operation of <F7> toggle
"       - <F7> to turn spelling on
"       - Repeated <F7> will move to next misspelled word
"       - <SHIFT+F7> will move to previous misspelled word
"       - <CTL+F7> will toggle spelling off
"       - <CTL+SHIFT+F7> Toggle dictionary en_ca, en_us
"
"       - When <F7> is pressed, echo usage instructions in status line such as
"         zg: add word, <F7> next, <S-F7>: previous, z=:word suggestion
"
"   - Add section to status bar to indicate current spell language
"
"   ]s  - Move to previous misspelled word.
"   [s  - Move to next misspelled word.
"   zg  - Add word to dictionary (good word).
"   z=  - Word suggestion.
"
" KEYMAP TYPES
" https://vim.fandom.com/wiki/Mapping_keys_in_Vim_-_Tutorial_(Part_1)
"

" ==============================================================================
" Spell Check:
" ==============================================================================
""let g:spellLanguages=["en_ca","en_us"]
function! SpellCheck(mode)
    echo "spelllang: " &spelllang
    let mode=a:mode

    " Disable spelling
    if mode == 'nospell'
        ""echo "nospell"
        setlocal nospell
        return
    endif

    if mode == 'spell' && &spell
        let mode='next'
    endif

    " Set'spellLanguages' index position
    if mode == 'spell' || mode == 'spelllang'
        if !empty(&spelllang)
            " Current index position
            let b:spellLangIndex=index(g:spellLanguages, &spelllang)

            " Add unknown spelling languages to 'spellLanguages'
            if b:spellLangIndex < 0
                ""echo "ADD unknown spelllang"
                call add(g:spellLanguages, &spelllang)
                let b:spellLangIndex=index(g:spellLanguages, &spelllang)
            endif
        else
            ""echo "Set index to 0 - SPELLLANG EMPTY"
            let b:spellLangIndex=0
        endif
        ""echo "index-updated: " b:spellLangIndex
    endif

    " toggle next 'spelllang'
    if mode == 'spelllang'
        ""echo "spelllang"
        let b:spellLangIndex=b:spellLangIndex+1
        if b:spellLangIndex>=len(g:spellLanguages) | let b:spellLangIndex=0 | endif
    endif

   " Enable spelling
    if !&spell || mode == 'spelllang'
        ""echo "enable"
        execute "setlocal spell spelllang=".get(g:spellLanguages, b:spellLangIndex)

    " Move to next misspelled word.
    elseif mode == 'next'
        ""echo "next"
        normal! ]s
        ""call QuickSpell()

    " Move to previous misspelled word.
    elseif mode == 'prev'
        ""echo "prev"
        normal! [s

    endif
    "echo "spell checking language:" g:spellLanguages[b:spellLangIndex]

endfunction


" ==============================================================================
" XXX: Unused
" QuickSpell:
" ==============================================================================
" Don't hijack the entire screen for spell checking, just show the top 9 results
" in they commandline.
" Press 0 for the full list. Any key press that's not a valid option (1-9) will
" behave as normal.
fun! QuickSpell()
    if &spell is 0
        echohl Error | echo "Spell checking not enabled" | echohl None
        return
    endif

    " Separator between items.
    let l:sep = ' | '

    " Show as many columns as will fit in the window.
    let l:sug = spellsuggest(expand('<cword>'), 9)
    let l:c = 0
    for l:i in range(0, len(l:sug))
        let l:c += len(l:sug[l:i - 1]) + len(printf('%d ', l:i + 1))
        " The -5 is needed to prevent some hit-enter prompts, even when there is
        " enough space (bug?)
        if l:c + (len(l:sep) * l:i) >= &columns - 5
            break
        endif
    endfor

    " Show options; make it stand out a bit.
    echohl QuickFixLine
    echo join(map(l:sug[:l:i - 1], {i, v -> printf('%d %s', l:i+1, l:v)}), l:sep)
    echohl None

    " Get answer.
    let l:char = nr2char(getchar())

    " Display regular spell screen on 0.
    if l:char is# '0'
        normal! z=
        return
    endif

    let l:n = str2nr(l:char)

    " Feed the character if it's not a number, so it's easier to do e.g. "ciw".
    if l:n is 0 || l:n > len(l:sug)
        return feedkeys(l:char)
    endif

    " Replace!
    exe printf("normal! ciw%s\<Esc>", l:sug[l:n-1])
    echo
endfun


" ==============================================================================
" Spelling Default Function Key Bindings:
" ==============================================================================
"
"       spell: Enable, select next word.
"              <F7>
"
"        prev: Select previous word.
"              <SHIFT>+<F7>
"
"     nospell: Disable spelling.
"              <CONTROL>+<F7>
"
"   spelllang: Toggle between spelling languages defined in
"              'g:spellLanguages'.
"              <CONTROL>+<SHIFT>+<F7>
"
" TODO:  Not yet functional
" Disable Spelling Default Key Bindings:
" 
" Disables enabling default key bindings for provided options:
"
"         all: All bindings
"       spell: <F7> Enable spelling and select next word.
"        prev: <SHIFT>+<F7> Select previous word.
"     nospell: <CONTROL>+<F7> Disable spelling.
"   spelllang: <CONTROL>+<SHIFT>+<F7> Spelling languages toggle.
"     suggest: <CONTROL>+<SPACE> Word suggestion.
"" let g:spellKeyBindingsDisable=["all"]
nmap <silent> <F7> :call SpellCheck('spell')<CR>
nmap <silent> <S-F7> :call SpellCheck('prev')<CR>
nmap <silent> <C-F7> :call SpellCheck('nospell')<CR>
nmap <silent> <C-S-F7> :call SpellCheck('spelllang')<CR>

" Word suggestions (<CONTROL>+<SPACE>)
inoremap <expr> <C-@>  pumvisible() ?  "\<C-n>" : "\<C-x>s"
nnoremap <expr> <C-@> pumvisible() ?  "i\<C-n>" : "i\<C-x>s"

" XXX: Unused
" QuickSpell
""nnoremap z= :call QuickSpell()<CR>

" vim:set ft=vim et sw=4 ts=4 sts=4:
