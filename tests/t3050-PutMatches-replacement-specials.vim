" Test putting first matches with replacement specials.
" Tests that a literal &;; separator is removed from the last element, but \0 is
" not.

edit text.txt
1
$PutMatches!/\<fo\w\>/&;;/
$PutMatches!/\<.....\>/\0;;/

call vimtest#SaveOut()
call vimtest#Quit()
