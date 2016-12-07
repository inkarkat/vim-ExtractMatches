" Test yanking around a multi-line match.

call vimtest#StartTap()
call vimtap#Plan(1)
edit longer.txt

let @/ = 'Cum\_.*fox'
GrepRangeToReg .-1,.+1
call vimtap#Is(@@, "materia, cinis elementi similis cum folio, de quo ludunt venti.\nCum sit foo.\nspacer two\nStultus fox, for bar and baz and quux.\nspacer three\n", 'Yank current line range to default register')

call vimtest#Quit()
