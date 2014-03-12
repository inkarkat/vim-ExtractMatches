" Test substituting and yanking all and first matches.

call vimtest#StartTap()
call vimtap#Plan(4)
let @@ = ''
let @a = ''
edit text.txt

SubstituteAndYank/\<fo\w\>/<&>/g/(&)/
call vimtap#Is(@@, "(foo)(foo)(foo)(fox)(for)", 'Yank replacement matches to default register')

SubstituteAndYank/\<...\(..\)\>/\0\1//(\1)/a
call vimtap#Is(@@, "(foo)(foo)(foo)(fox)(for)", 'Default register unchanged when register is specified')
call vimtap#Is(@a, "(ti)(is)(em)", 'Yank replacement matches to default register')

let @/ = '\<vehe\w\+'
SubstituteAndYank//[\0]//(\0)/
call vimtap#Is(@@, "(vehementi)", 'Yank last search pattern')

call vimtest#SaveOut()
call vimtest#Quit()
