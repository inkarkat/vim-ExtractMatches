" Test yanking of a single closed fold.

call vimtest#StartTap()
call vimtap#Plan(1)
let @@ = ''
edit text.txt
%fold

3GrepToReg/\<foo\>/
call vimtap#Is(@@, "Estuans interius foo vehementi in bar loquor foo menti: factus de\nCum sit foo.\n", 'Yank matching lines to default register')

call vimtest#Quit()
