" Test printing unique matches with predicate.

edit text.txt

echomsg 'start'
PrintUniqueMatches/\<\w\{3}\>/v:val.matchCount < 5
echomsg 'end'

echomsg 'start'
PrintUniqueMatches/\<\([fl]\)\w\+\>/\1&-/len(ingo#str#trcd(v:val.replacement, 'o')) > 1 && v:val.acceptedCount < 3
echomsg 'end'

call vimtest#Quit()
