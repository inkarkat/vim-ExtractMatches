" Test printing all matches within a single closed fold.

edit text.txt
%fold

echomsg 'start'
3PrintMatches/\<fo\w\>/
echomsg 'end'

call vimtest#Quit()
