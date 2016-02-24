" Test putting all unique matches.

edit text.txt
1
$PutUniqueMatches/\<fo\w\>/

call vimtest#SaveOut()
call vimtest#Quit()
