" Test substituting and yanking all and first matches within a single closed fold.

call vimtest#StartTap()
call vimtap#Plan(1)
let @@ = ''
edit text.txt
%fold

3SubstituteAndYank/\<fo\w\>/<&>/g/(&)/
call vimtap#Is(@@, "(foo)(foo)(foo)(fox)(for)", 'Yank replacement matches to default register')

call vimtest#SaveOut()
call vimtest#Quit()
