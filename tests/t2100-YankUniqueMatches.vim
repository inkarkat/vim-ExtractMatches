" Test yanking all unique matches.

call vimtest#StartTap()
call vimtap#Plan(4)
let @@ = ''
let @a = ''
edit text.txt

YankUniqueMatches/\<fo\w\>/
call vimtap#Is(@@, "foo\nfox\nfor\n", 'Yank matches to default register')

YankUniqueMatches!/\<fo\w\>/a
call vimtap#Is(@@, "foo\nfox\nfor\n", 'Default register unchanged when register is specified')
call vimtap#Is(@a, "foo\nfox\n", 'Yank first matches to register a')

let @/ = '\<i.'
YankUniqueMatches
call vimtap#Is(@@, "in\n", 'Yank last search pattern')

call vimtest#Quit()
