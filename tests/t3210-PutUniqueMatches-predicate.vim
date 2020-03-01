" Test putting unique matches with predicate.

edit text.txt
1
$PutUniqueMatches/\<\([fl]\)\w\+\>/\1&-/ len(ingo#str#trcd(v:val.replacement, 'o')) > 1 && v:val.acceptedCount < 3

call vimtest#SaveOut()
call vimtest#Quit()
