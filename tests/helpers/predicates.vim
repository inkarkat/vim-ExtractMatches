let g:toggle = 0
function! MyPredicate() abort
    let g:toggle = ! g:toggle
    return g:toggle
endfunction

function! MyContextPredicate( context ) abort
    return (a:context.matchStart[1] > 9)
endfunction
