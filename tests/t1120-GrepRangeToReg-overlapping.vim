" Test yanking overlapping ranges.

call vimtest#StartTap()
call vimtap#Plan(2)
let @a = ''
edit longer.txt

let @/ = 'foo'
GrepRangeToReg .-1,.+1 a
call vimtap#Is(@a, "spacer one\nEstuans interius foo vehementi in bar loquor foo menti: factus de\nmateria, cinis elementi similis cum folio, de quo ludunt venti.\nCum sit foo.\nspacer two\ngaga nolos\ncomparor Foo flu labenti, sub eodem foobar tramite nunquam permanenti.\n}\n", 'yank foo plus one around')

GrepRangeToReg /\<foo\>/ ?{?+1,/}/-1 b
call vimtap#Is(@b, "spacer one\nEstuans interius foo vehementi in bar loquor foo menti: factus de\nmateria, cinis elementi similis cum folio, de quo ludunt venti.\nCum sit foo.\nspacer two\nStultus fox, for bar and baz and quux.\nspacer three\n", 'yank \<foo\> surrounded by {...}')

call vimtest#Quit()
