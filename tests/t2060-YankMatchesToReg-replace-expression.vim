" Test yanking all matches with replace expression.

call vimtest#StartTap()
call vimtap#Plan(2)
let @@ = ''
edit text.txt

YankMatchesToReg/\<fo\w\>/\='<' . submatch(0) . '>'/
call vimtap#Is(@@, '<foo><foo><foo><fox><for>', 'Yank replace-expression matches to default register')

YankMatchesToReg/\<fo\(\w\)\>/\=submatch(0) . submatch(1) . ', '/
call vimtap#Is(@@, 'fooo, fooo, fooo, foxx, forr, ', 'Yank submatch(1) replace-expression matches to default register')

call vimtest#Quit()
