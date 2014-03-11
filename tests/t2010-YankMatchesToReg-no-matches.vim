" Test error when the pattern doesn't match.

call vimtest#StartTap()
call vimtap#Plan(2)
let @a = ''
edit text.txt
try
    YankMatchesToReg/doesNotExist/a
    call vimtap#Fail('expected exception')
catch
    call vimtap#err#Thrown('E486: Pattern not found: doesNotExist', 'error shown')
endtry
call vimtap#Is(@a, '', 'Register unchanged')

call vimtest#Quit()
