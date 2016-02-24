" Test printing all matches with replacement.

edit text.txt

echomsg 'start'
PrintMatches/\<fo\(\w\)\>/"&\1", /
echomsg 'end'

call vimtest#Quit()
