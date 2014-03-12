" Test substituting and yanking with special numbering.

call vimtest#StartTap()
call vimtap#Plan(2)
let @@ = ''
edit text.txt

SubstituteAndYank/\<fo\w\>/\#:&/g/\#=&\n/
call vimtap#Is(@@, "1=foo\n2=foo\n3=foo\n4=fox\n5=for\n", 'Yank replacement with \# matches to default register')

SubstituteAndYank/\<\w\w\w\(\w\w\)\>/\=v:key . '>' . submatch(0)//\=v:key . '=' . submatch(1) . "\n"/
call vimtap#Is(@@, "0=ti\n1=is\n2=em\n", 'Yank replacement matches to default register')

call vimtest#SaveOut()
call vimtest#Quit()
