" Test yanking matches with predicate.

call vimtest#StartTap()
call vimtap#Plan(9)
let @@ = ''
let @a = ''
edit text.txt

YankMatches/\<fo\w\>/ 42==11
call vimtap#Is(@@, '', 'Nothing extracted with always-false predicate')

YankMatches/\<fo\w\>/ 42==42/
call vimtap#Is(@@, ' 42==42 42==42 42==42 42==42 42==42', 'With trailing separator, what looks like predicate is taken as replacement')

YankMatches/\<fo\w\>/ 42==42
call vimtap#Is(@@, "foo\nfoo\nfoo\nfox\nfor\n", 'Everything extracted with always-true predicate')

YankMatches!/\<fo\w\>/a 11!=0
call vimtap#Is(@@, "foo\nfoo\nfoo\nfox\nfor\n", 'Default register unchanged when register is specified')
call vimtap#Is(@a, "foo\nfoo\nfox\n", 'Yank first matches to register a with always-true predicate')

let g:toggle = 0
function! MyPredicate() abort
    let g:toggle = ! g:toggle
    return g:toggle
endfunction
YankMatches/\<fo\w\>/b MyPredicate()
call vimtap#Is(@b, "foo\nfoo\nfor\n", 'Every second match extracted with toggle predicate without context')

function! MyContextPredicate( context ) abort
    return (a:context.matchStart[1] > 9)
endfunction
YankMatches/\<\w\{3}\>/b MyContextPredicate(v:val)
call vimtap#Is(@b, "foo\nbar\nfoo\ncum\nquo\nfor\nbar\nand\nbaz\nand\nFoo\nflu\nsub\n", 'Every match after column 9 extracted with context predicate')

YankMatches/\<\w\{3}\>/c v:val.matchCount < 5
call vimtap#Is(@c, "foo\nbar\nfoo\ncum\n", 'First four matches extracted via direct context expression')

YankMatches/\<f\w\+\>/d len(ingo#str#trcd(v:val.match, 'o')) > 1
call vimtap#Is(@d, "foo\nfoo\nfolio\nfoo\nfoobar\n", 'Matches with more than one o extracted via direct context expression')

call vimtest#Quit()
