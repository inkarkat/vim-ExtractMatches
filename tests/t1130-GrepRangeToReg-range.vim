" Test yanking within a range.

call vimtest#StartTap()
call vimtap#Plan(4)
let @a = ''
edit longer.txt

let @/ = '^bar'
5,22GrepRangeToReg .-2,.+2 a
call vimtap#Is(@a, "hi\nbar\n}\n{\n}\n{\nbar\n", 'yank ^bar and two lines around it')

/^#START/+1,/^#END/-1GrepRangeToReg /^bar/ .-2,.+2 b
call vimtap#Is(@b, "hi\nbar\n}\n{\n}\n{\nbar\n", 'yank ^bar and two lines around it')

11,13GrepRangeToReg /foo/ % c
call vimtap#Is(@c, "materia, cinis elementi similis cum folio, de quo ludunt venti.\nCum sit foo.\nspacer two\n", 'yank foo and as much as allowed')

1,19GrepRangeToReg /foo/ .+1 d
call vimtap#Is(@d, "materia, cinis elementi similis cum folio, de quo ludunt venti.\nspacer two\n", "yank line after foo; out of range for last match")

call vimtest#Quit()
