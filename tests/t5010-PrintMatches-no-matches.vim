" Test error when the pattern doesn't match.

call vimtest#StartTap()
call vimtap#Plan(1)
edit text.txt
try
    PrintMatches/doesNotExist/
    call vimtap#Fail('expected exception')
catch
    call vimtap#err#Thrown('E486: Pattern not found: doesNotExist', 'error shown')
endtry

call vimtest#Quit()
