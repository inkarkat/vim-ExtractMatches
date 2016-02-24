" Test printing all matches within a range.

edit text.txt

echomsg 'start'
2,4PrintMatches/\c\<foo\>/
echomsg 'end'
call vimtap#Is(@@, "foo\n", 'Yank matches to default register')

call vimtest#Quit()
