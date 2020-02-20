" Test yanking all matches within a single closed fold.

call vimtest#StartTap()
call vimtap#Plan(2)
let @@ = ''
edit text.txt
%fold

3YankMatches/\<fo\w\>/
call vimtap#Is(@@, "foo\nfoo\nfoo\nfox\nfor\n", 'Yank matches to default register')
call vimtap#Ok(! &modified, 'Buffer not modified')

call vimtest#Quit()
