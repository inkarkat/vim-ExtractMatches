" Test printing all matches with replacement specials.

edit text.txt

echomsg 'start'
PrintMatches/\<fo\w\>/&;;/
echomsg 'end'

echomsg 'start'
PrintMatches/\<fo\w\>/\0;;/
echomsg 'end'

echomsg 'start'
PrintMatches/\<fo\w\>/&\n/
echomsg 'end'

echomsg 'start'
PrintMatches/vehe\zsm.n\zeti/<&>/
echomsg 'end'

echomsg 'start'
PrintMatches/\%>3l\%>2v\<fo./<&>/
echomsg 'end'

call vimtest#Quit()
