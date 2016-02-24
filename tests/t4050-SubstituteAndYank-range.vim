" Test substituting and yanking within a line and passed range.

call vimtest#StartTap()
call vimtap#Plan(2)
let @@ = ''
let @a = ''
edit text.txt
1

SubstituteAndYank/\<fo\w\>/<&>/g/(&)/
call vimtap#Is(@@, "(foo)(foo)", 'Yank replacement matches to default register')

2,4SubstituteAndYank/\<...\>/[\0]//(\0)/a
call vimtap#Is(@a, "(cum)(Cum)(fox)", 'Yank replacement matches to register a')

call vimtest#SaveOut()
call vimtest#Quit()
