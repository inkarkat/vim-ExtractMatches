" Test error when the pattern doesn't match.

call vimtest#StartTap()
call vimtap#Plan(3)
edit text.txt
let s:lineNum = line('$')
try
    $PutMatches/doesNotExist/
    call vimtap#Fail('expected exception')
catch
    call vimtap#err#Thrown('E486: Pattern not found: doesNotExist', 'error shown')
endtry
call vimtap#Ok(&modified, 'Buffer is modified')
call vimtap#Is(line('$'), s:lineNum, 'Number of lines unchanged')

call vimtest#Quit()
