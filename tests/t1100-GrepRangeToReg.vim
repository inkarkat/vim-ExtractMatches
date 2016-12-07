" Test yanking all matching lines.

call vimtest#StartTap()
call vimtap#Plan(4)
let @@ = ''
let @a = ''
edit longer.txt

let @/ = '\<foo\>'
GrepRangeToReg .
call vimtap#Is(@@, "Estuans interius foo vehementi in bar loquor foo menti: factus de\nCum sit foo.\n", 'Yank current line range to default register')

GrepRangeToReg! /^\u/ . a
call vimtap#Is(@@, "Estuans interius foo vehementi in bar loquor foo menti: factus de\nCum sit foo.\n", 'Default register unchanged when register is specified')
call vimtap#Is(@a, "beginning\nsome bar first\n{\n#START\nhi\nbar\n}\n{\nspacer one\nmateria, cinis elementi similis cum folio, de quo ludunt venti.\nspacer two\nspacer three\n}\n{\ngaga nolos\ncomparor Foo flu labenti, sub eodem foobar tramite nunquam permanenti.\n}\n{\nbar\n#END\n}\nmore bar\nend\n", 'Yank non-matching lines to register a')

let @/ = '\<vehe\w\+'
GrepRangeToReg .-1,.+1
call vimtap#Is(@@, "spacer one\nEstuans interius foo vehementi in bar loquor foo menti: factus de\nmateria, cinis elementi similis cum folio, de quo ludunt venti.\n", 'Yank last search pattern')

call vimtest#Quit()
