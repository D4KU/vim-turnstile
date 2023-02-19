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

" Return a regex matching the given word 'count' times with arbitrary many
" characters allowed before the first, behind the last, and in between each
" instance of 'word'
function! s:StartPattern(word, count)
    return '(%(.{-}' . a:word . '){' . string(a:count) . '}.{-})'
endfunction

" Return the last substring in 'haystack' that the pattern 'needle' matches
function! s:LastMatch(haystack, needle)
    let lst = []
    call substitute(a:haystack, a:needle, '\=add(lst, submatch(0))', 'g')
    if len(lst) == 0
        return ''
    endif
    return lst[len(lst) - 1]
endfunction

" Swap words adjacent to given infix word
function! turnstile#turn(infix)
    let l:magic = '\v'
    let l:skip = v:count1 - 1

    " Remove magic while parsing given word
    let l:infix = '\V' . a:infix . l:magic

    " The word and white space around it to stay in place
    let l:mid = '(\s*' . l:infix . '\s*)'

    " Generate pattern for neighbors of given word meant to be swapped
    let l:neigh = s:NeighborPattern()

    " If some instances of the given word ought to be skipped, count its
    " appearances in the left neighbor of the first word not to be skipped
    if l:skip > 0
        let l:start = s:StartPattern(l:infix, l:skip)
        let l:m = matchlist(getline('.'), l:magic . l:start . l:mid)
        let l:lneigh = s:LastMatch(l:m[1], l:magic . l:neigh)

        " Lower the skip count so that the words found in the left neighbor
        " aren't included in the first match group 'start'
        let l:skip -= count(l:lneigh, a:infix)
    endif

    " Generate pattern for left side of line meant to stay in place
    let l:start = s:StartPattern(l:infix, l:skip)

    " Identify all groups
    let l:m = matchlist(getline('.'), l:magic . l:start . l:neigh . l:mid . l:neigh . '(.*)')

    if len(l:m) > 5
        " Swap both neighbors
        call setline('.', l:m[1] . l:m[4] . l:m[3] . l:m[2] . l:m[5])
    endif
endfunction
