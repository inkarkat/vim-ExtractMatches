" Test error when no range supplied.

call vimtest#StartTap()
call vimtap#Plan(4)
let @a = ''
edit text.txt
call vimtap#err#Errors('Wrong syntax: Need to pass {range}', 'GrepRangeToReg', 'Syntax error shown')

let @/ = 'doesNotExistSearchPattern'
call vimtap#err#ErrorsLike('^E486: .*: doesNotExistSearchPattern', 'GrepRangeToReg x', 'Pattern not found error shown')

let @/ = 'doesNotExistSearchPattern'
call vimtap#err#ErrorsLike('^E486: .*: doesNotExistSearchPattern', 'GrepRangeToReg /rangeDoesNotExist/', 'Pattern not found error shown')
call vimtap#Is(@a, '', 'Register unchanged')

call vimtest#Quit()
