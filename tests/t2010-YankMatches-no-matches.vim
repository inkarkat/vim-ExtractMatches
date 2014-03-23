" Test error when the pattern doesn't match.

call vimtest#StartTap()
call vimtap#Plan(2)
let @a = ''
edit text.txt
call vimtap#err#Errors('E486: Pattern not found: doesNotExist', 'YankMatches/doesNotExist/a', 'error shown')
call vimtap#Is(@a, '', 'Register unchanged')

call vimtest#Quit()
