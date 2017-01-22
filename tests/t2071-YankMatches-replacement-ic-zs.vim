" Test yanking with a replace expression that changes to ignorecase and uses match limiting.

call vimtest#StartTap()
call vimtap#Plan(2)
let @@ = ''
edit text.txt

YankMatches/\ce\w\w\zs[UANSNTI]\{3,4}\>/<&>/
call vimtap#Is(@@, "<uans><nti><nti>", 'Yank \c..\zs replaced matches to default register')

YankMatches/e\ze[MEST]\{2}\c/<&>/
call vimtap#Is(@@, "<E><e><e>", 'Yank \ze..\c replaced matches to default register')

call vimtest#Quit()
