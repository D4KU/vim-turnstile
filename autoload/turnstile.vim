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

" Starting from the current one, return the number of the first line
" containing the given string
function! s:SeekLine(str)
    for l:i in range(line('.'), line('$'))
        if stridx(getline(l:i), a:str) >= 0
            return l:i
        endif
    endfor
endfunction

" Swap words adjacent to given infix word
function! turnstile#turn(infix)
    let l:magic = '\v'
    let l:skip = v:count1 - 1
    let l:lnum = s:SeekLine(a:infix)
    let l:line = getline(l:lnum)

    " Remove magic while parsing given word
    let l:infix = '\V' . a:infix . l:magic

    " The word and white space around it to stay in place
    let l:mid = '(\s*' . l:infix . '\s*)'

    " Generate pattern for neighbors of given word meant to be swapped
    let l:neigh = s:NeighborPattern()

    " Generate pattern for left side of line meant to stay in place
    let l:start = s:StartPattern(l:infix, l:skip)
    let l:m = matchlist(l:line, l:magic . l:start . l:mid . l:neigh)

    " Generate pattern for right side of line meant to stay in place.
    " Calculate number of infix occurrences that should be in this group:
    " All in line - all skipped - one in mid group - all in right neighbor
    let l:endcnt = count(l:line, a:infix) - skip - 1 - count(l:m[3], a:infix)
    let l:end = '(%(.*' . l:infix . '){' . string(endcnt) . '}.*)'

    if l:skip > 0
        " If some instances of the given word ought to be skipped, count its
        " appearances in the left neighbor of the first word not to be skipped
        let l:lneigh = s:LastMatch(l:m[1], l:magic . l:neigh)

        " Regenerate start group with lower skip count so that it doesn't
        " swallow the words found in the left neighbor
        let l:start = s:StartPattern(l:infix, l:skip - count(l:lneigh, a:infix))
    endif

    " Identify all groups
    let l:m = matchlist(l:line, l:magic . l:start . l:neigh . l:mid . l:neigh . l:end)

    if len(l:m) > 5
        " Swap both neighbors
        call setline(l:lnum, l:m[1] . l:m[4] . l:m[3] . l:m[2] . l:m[5])
    endif
endfunction
