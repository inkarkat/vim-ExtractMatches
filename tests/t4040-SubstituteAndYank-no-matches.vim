" Test error when the pattern doesn't match.

call vimtest#StartTap()
call vimtap#Plan(3)
let @@ = ''
edit text.txt
call vimtap#err#Errors('E486: Pattern not found: doesNotExist', 'SubstituteAndYank/doesNotExist/<&>/g/(&)/', 'error shown')
call vimtap#Ok(empty(@@), 'Default register not modified')
call vimtap#Ok(&modified, 'Buffer is modified')

call vimtest#SaveOut()
call vimtest#Quit()
