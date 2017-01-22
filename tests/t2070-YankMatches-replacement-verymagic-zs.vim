" Test yanking with a replace expression that changes to very magic and uses match limiting.

call vimtest#StartTap()
call vimtap#Plan(1)
let @@ = ''
edit text.txt

YankMatches/\v \zsqu+.>/<&>/
call vimtap#Is(@@, "<quo><quux>", 'Yank \v..\zs replaced matches to default register')

call vimtest#Quit()
