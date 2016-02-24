" Test error when the pattern doesn't match.

call vimtest#StartTap()
call vimtap#Plan(2)
let @a = ''
edit text.txt
call vimtap#err#ErrorsLike('^E486: .*: doesNotExist', 'YankMatches/doesNotExist/a', 'Pattern not found error shown')
call vimtap#Is(@a, '', 'Register unchanged')

call vimtest#Quit()
