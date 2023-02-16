" Returns a regex containing one anonymous group for each given string of
" which one must be matched
" As in  %(match me)|%(or me)
function! s:Or(...)
    return join(map(copy(a:000), '"%(" .. v:val .. ")"'), '|')
endfunction

" Return a regex matching anything expected next to an infix
" operator
function! s:NeighborPattern()
    " Pair of parenthesis with optional content
    let l:paren = '\(.{-}\)'

    " Pair of squared brackets with at least one character in between
    let l:brack = '\[.{-1,}\]'

    " Content between single quotes
    let l:quot = "'.{-}'"

    " Content between doule quotes
    let l:dquot = '".{-}"'

    " Floating point number
    let l:float = '-?\d*\.\d+f?'

    " Integer
    let l:int = '-?%(\d+_)*\d+[ul]?'

    " Name of variable, function, class, bool value, ...
    let l:iden = '\h\w*'

    " A chain of members, e.g.:
    " * foo.bar
    " * foo[0].bar.baz()
    " * foo.bar[0]()()
    " * foo[0][bar()]
    let l:chain = l:iden . '%(' . s:Or('\.' . l:iden, l:paren, l:brack) . ')*'
    return '(' . s:Or(l:chain, l:float, l:int, l:paren, l:quot, l:dquot) . ')'
endfunction

" Swap words adjacent to given infix word
function! turnstile#turn(infix)
    " Remove magic while parsing given word
    let l:infix = '\V' . a:infix . '\v'

    let l:neigh = s:NeighborPattern()

    " The word and white space around it to stay in place
    let l:mid = '(\s*' . l:infix . '\s*)'

    " Left side of the left neighbor of the given word to stay in place
    " Skip some instances of the given word depending on the given count
    let l:start = '\v(%(.{-}' . l:infix . '){' . string(v:count1 - 1) . '}.{-})'

    " Right side of the right neighbor of the given word to stay in place
    let l:end = '(.*)'

    " Identify all groups
    let l:m = matchlist(getline('.'), l:start . l:neigh . l:mid . l:neigh . l:end)

    if len(l:m) > 5
        " Swap both neighbors
        call setline('.', l:m[1] . l:m[4] . l:m[3] . l:m[2] . l:m[5])
    endif
endfunction
