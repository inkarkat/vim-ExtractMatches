" Test substituting and yanking all unique matches.

call vimtest#SkipAndQuitIf(v:version < 704 || v:version == 704 && ! has('patch2119'), 'Need support for recursive sub-replace-expression')
call vimtest#StartTap()
call vimtap#Plan(4)
let @@ = ''
let @a = ''
edit text.txt

%SubstituteAndYankUnique/\<fo\w\>/<&>/g/(&)/
call vimtap#Is(@@, "(foo)(fox)(for)", 'Yank replacement matches to default register')

%SubstituteAndYankUnique/\<.\zs..\(..\)\>/\0\1/g/(\1)/a
call vimtap#Is(@@, "(foo)(fox)(for)", 'Default register unchanged when register is specified')
call vimtap#Is(@a, "(ti)(is)(io)(em)", 'Yank replacement matches to register a')

let @/ = '\<vehe\w\+'
%SubstituteAndYankUnique//[\0]//(\0)/
call vimtap#Is(@@, "(vehementi)", 'Yank last search pattern')

call vimtest#SaveOut()
call vimtest#Quit()
