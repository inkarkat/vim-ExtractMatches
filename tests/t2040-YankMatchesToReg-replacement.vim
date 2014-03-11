" Test yanking all matches with replacement.

call vimtest#StartTap()
call vimtap#Plan(1)
let @@ = ''
edit text.txt

YankMatchesToReg/\<fo\(\w\)\>/"&\1", /
call vimtap#Is(@@, '"fooo", "fooo", "fooo", "foxx", "forr", ', 'Yank replaced matches to default register')

call vimtest#Quit()
