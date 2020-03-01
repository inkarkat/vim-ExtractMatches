" Test printing matches with predicate.

source helpers/predicates.vim
call vimtest#StartTap()
call vimtap#Plan(1)
edit text.txt

call vimtap#err#ErrorsLike('^E486: .*: \\<fo\\w\\>', 'PrintMatches/\<fo\w\>/ 42==11', 'Pattern not found error shown')

echomsg 'start'
PrintMatches/\<fo\w\>/ 42==42/
echomsg 'end'

echomsg 'start'
PrintMatches/\<fo\w\>/ 42==42
echomsg 'end'

echomsg 'start'
PrintMatches!/\<fo\w\>/11!=0
echomsg 'end'

echomsg 'start'
PrintMatches/\<fo\w\>/MyPredicate()
echomsg 'end'

echomsg 'start'
PrintMatches/\<\w\{3}\>/MyContextPredicate(v:val)
echomsg 'end'

echomsg 'start'
PrintMatches/\<\w\{3}\>/v:val.matchCount < 5
echomsg 'end'

echomsg 'start'
PrintMatches/\<f\w\+\>/len(ingo#str#trcd(v:val.match, 'o')) > 1
echomsg 'end'

call vimtest#Quit()
