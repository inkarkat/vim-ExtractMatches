" Test error when the pattern doesn't match.

call vimtest#StartTap()
call vimtap#Plan(3)
edit text.txt
let s:lineNum = line('$')
call vimtap#err#Errors('E486: Pattern not found: doesNotExist', '$PutMatches/doesNotExist/', 'error shown')
call vimtap#Ok(&modified, 'Buffer is modified')
call vimtap#Is(line('$'), s:lineNum, 'Number of lines unchanged')

call vimtest#Quit()
