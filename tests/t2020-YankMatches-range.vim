" Test yanking all matches within a range.

call vimtest#StartTap()
call vimtap#Plan(1)
let @@ = ''
edit text.txt

2,4YankMatches/\c\<foo\>/
call vimtap#Is(@@, "foo\n", 'Yank matches to default register')

call vimtest#Quit()
