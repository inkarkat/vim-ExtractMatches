" Test putting all matches.

edit text.txt
1
$PutMatches/\<fo\w\>/

call vimtest#SaveOut()
call vimtest#Quit()
