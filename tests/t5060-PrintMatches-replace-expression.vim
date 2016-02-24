" Test printing all matches with replace expression.

edit text.txt

echomsg 'start'
PrintMatches/\<fo\w\>/\='<' . submatch(0) . '>'/
echomsg 'end'

echomsg 'start'
PrintMatches/\<fo\(\w\)\>/\=submatch(0) . submatch(1) . ', '/
echomsg 'end'

call vimtest#Quit()
