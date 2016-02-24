" Test yanking all matching lines.

call vimtest#StartTap()
call vimtap#Plan(4)
let @@ = ''
let @a = ''
edit text.txt

GrepToReg/\<foo\>/
call vimtap#Is(@@, "Estuans interius foo vehementi in bar loquor foo menti: factus de\nCum sit foo.\n", 'Yank matching lines to default register')

GrepToReg!/^\u/a
call vimtap#Is(@@, "Estuans interius foo vehementi in bar loquor foo menti: factus de\nCum sit foo.\n", 'Default register unchanged when register is specified')
call vimtap#Is(@a, "materia, cinis elementi similis cum folio, de quo ludunt venti.\ncomparor Foo flu labenti, sub eodem foobar tramite nunquam permanenti.\n", 'Yank non-matching lines to register a')

let @/ = '\<vehe\w\+'
GrepToReg
call vimtap#Is(@@, "Estuans interius foo vehementi in bar loquor foo menti: factus de\n", 'Yank last search pattern')

call vimtest#Quit()
