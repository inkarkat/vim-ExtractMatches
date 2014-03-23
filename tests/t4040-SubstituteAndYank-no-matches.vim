" Test error when the pattern doesn't match.

call vimtest#StartTap()
call vimtap#Plan(3)
let @@ = ''
edit text.txt
try
    SubstituteAndYank/doesNotExist/<&>/g/(&)/
    call vimtap#Fail('expected exception')
catch
    call vimtap#err#Thrown('E486: Pattern not found: doesNotExist', 'error shown')
endtry
call vimtap#Ok(empty(@@), 'Default register not modified')
call vimtap#Ok(&modified, 'Buffer is modified')

call vimtest#SaveOut()
call vimtest#Quit()
