" Test deleting and yanking like with a :DeleteMatches command.

call vimtest#StartTap()
call vimtap#Plan(2)
let @@ = ''
let @a = ''
edit text.txt

1SubstituteAndYank/\<fo\w\>\s//g//
call vimtap#Is(@@, "foo \nfoo \n", 'Yank original matches to default register')

2,4SubstituteAndYank/\<...\>/&///a
call vimtap#Is(@a, "cum\nCum\nfox\n", 'Yank original matches to register a')

call vimtest#SaveOut()
call vimtest#Quit()
