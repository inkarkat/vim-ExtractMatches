" Test printing all unique matches.

edit text.txt

echomsg 'start'
PrintUniqueMatches/\<fo\w\>/
echomsg 'end'

echomsg 'start'
PrintUniqueMatches!/\<fo\w\>/
echomsg 'end'

let @/ = '\<i.'
echomsg 'start'
PrintUniqueMatches
echomsg 'end'

call vimtest#Quit()
