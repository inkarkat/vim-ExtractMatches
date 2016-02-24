" Test putting all matches of the last search pattern.

edit text.txt
1
let @/ = '\<vehe\w\+'
$PutMatches

call vimtest#SaveOut()
call vimtest#Quit()
