" Test putting matches with predicate.

source helpers/predicates.vim
edit text.txt
1
$PutMatches/\<\w\{3}\>/MyContextPredicate(v:val)

call vimtest#SaveOut()
call vimtest#Quit()
