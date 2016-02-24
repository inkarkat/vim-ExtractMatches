" Test putting all matches with replacement.
" Tests that matches are concatenated in one line.

edit text.txt
1
$PutMatches/\<fo\(\w\)\>/"&\1", /

call vimtest#SaveOut()
call vimtest#Quit()
