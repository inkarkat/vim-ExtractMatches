" Test substituting and yanking with specials.

call vimtest#StartTap()
call vimtap#Plan(1)
let @@ = ''
edit text.txt

%SubstituteAndYank/\<fo\w\>/\t<&>\n/g/\t(&)\n/
call vimtap#Is(@@, "\t(foo)\n\t(foo)\n\t(foo)\n\t(fox)\n\t(for)\n", 'Yank replacement with \t\n matches to default register')

call vimtest#SaveOut()
call vimtest#Quit()
