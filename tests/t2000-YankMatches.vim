" Test yanking all matches.

call vimtest#StartTap()
call vimtap#Plan(5)
let @@ = ''
let @a = ''
edit text.txt

YankMatches/\<fo\w\>/
call vimtap#Is(@@, "foo\nfoo\nfoo\nfox\nfor\n", 'Yank matches to default register')
call vimtap#Ok(! &modified, 'Buffer not modified')

YankMatches!/\<fo\w\>/a
call vimtap#Is(@@, "foo\nfoo\nfoo\nfox\nfor\n", 'Default register unchanged when register is specified')
call vimtap#Is(@a, "foo\nfoo\nfox\n", 'Yank first matches to register a')

let @/ = '\<vehe\w\+'
YankMatches
call vimtap#Is(@@, "vehementi\n", 'Yank last search pattern')

call vimtest#Quit()
