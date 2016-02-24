" Test yanking all matching lines within a range.

call vimtest#StartTap()
call vimtap#Plan(1)
let @@ = ''
edit text.txt

2,4GrepToReg/\<foo\>/
call vimtap#Is(@@, "Cum sit foo.\n", 'Yank matching line to default register')

call vimtest#Quit()
