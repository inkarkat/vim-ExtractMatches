" Test yanking all matching lines, including a match in the last.

call vimtest#StartTap()
call vimtap#Plan(1)
let @@ = ''
edit text.txt

GrepToReg/er/
call vimtap#Is(@@, "Estuans interius foo vehementi in bar loquor foo menti: factus de\nmateria, cinis elementi similis cum folio, de quo ludunt venti.\ncomparor Foo flu labenti, sub eodem foobar tramite nunquam permanenti.\n", 'Yank matching lines to default register')

call vimtest#Quit()
