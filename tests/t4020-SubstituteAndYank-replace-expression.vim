" Test substituting and yanking with replace expressions.

call vimtest#StartTap()
call vimtap#Plan(4)
let @@ = ''
let @a = ''
edit text.txt

%SubstituteAndYank/\<fo\w\>/\='<' . submatch(0) . '>'/g/\='(' . submatch(0) . ')'/
call vimtap#Is(@@, "(foo)(foo)(foo)(fox)(for)", 'Yank replacement matches to default register')

%SubstituteAndYank/\<...\(..\)\>/\0\1//\='(' . submatch(1) . ')'/a
call vimtap#Is(@@, "(foo)(foo)(foo)(fox)(for)", 'Default register unchanged when register is specified')
call vimtap#Is(@a, "(ti)(is)(em)", 'Yank replacement matches to register a')

let @/ = '\<vehe\w\+'
%SubstituteAndYank//\='[' . submatch(0) . ']'//(\0)/
call vimtap#Is(@@, "(vehementi)", 'Yank last search pattern')

call vimtest#SaveOut()
call vimtest#Quit()
