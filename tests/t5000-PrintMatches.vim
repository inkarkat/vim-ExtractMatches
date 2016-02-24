" Test printing all matches.

edit text.txt

echomsg 'start'
PrintMatches/\<fo\w\>/
echomsg 'end'

call vimtest#StartTap()
call vimtap#Plan(1)
call vimtap#Ok(! &modified, 'Buffer not modified')


echomsg 'start'
PrintMatches!/\<fo\w\>/
echomsg 'end'

let @/ = '\<vehe\w\+'
echomsg 'start'
PrintMatches
echomsg 'end'

call vimtest#Quit()
