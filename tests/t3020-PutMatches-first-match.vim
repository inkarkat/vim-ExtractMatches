" Test putting the first match in each line.

edit text.txt
1
$PutMatches!/\<fo\w\>/

call vimtest#SaveOut()
call vimtest#Quit()
