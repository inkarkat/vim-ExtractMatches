" Test yanking all matches with replacement specials.

call vimtest#StartTap()
call vimtap#Plan(5)
let @@ = ''
edit text.txt

YankMatches/\<fo\w\>/&;;/
call vimtap#Is(@@, 'foo;;foo;;foo;;fox;;for', 'Yank &;; replaced matches to default register')
YankMatches/\<fo\w\>/\0;;/
call vimtap#Is(@@, 'foo;;foo;;foo;;fox;;for;;', 'Yank \0;; replaced matches to default register')

YankMatches/\<fo\w\>/&\n/
call vimtap#Is(@@, "foo\nfoo\nfoo\nfox\nfor", 'Yank &\n replaced matches to default register')

YankMatches/vehe\zsm.n\zeti/<&>/
call vimtap#Is(@@, "<men>", 'Yank \zs..\ze replaced matches to default register')

YankMatches/\%>3l\%>2v\<fo./<&>/
call vimtap#Is(@@, "<fox><for><foo>", 'Yank \%>3l\%>2v replaced matches to default register')

call vimtest#Quit()
