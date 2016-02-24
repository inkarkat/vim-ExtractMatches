" Test putting first matches with replace expressions.

edit text.txt
1
$PutMatches!/\<fo\(\w\)\>/\='<' . submatch(0) . '>'/

call vimtest#SaveOut()
call vimtest#Quit()
