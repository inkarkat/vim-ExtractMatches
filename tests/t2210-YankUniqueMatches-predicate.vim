" Test yanking unique matches with predicate.

call vimtest#StartTap()
call vimtap#Plan(2)
edit text.txt

YankUniqueMatches/\<\w\{3}\>/c v:val.matchCount < 5
call vimtap#Is(@c, "foo\nbar\ncum\nquo\n", 'First four unique matches extracted via direct context expression')

YankUniqueMatches/\<\([fl]\)\w\+\>/\1&-/d len(ingo#str#trcd(v:val.replacement, 'o')) > 1 && v:val.acceptedCount < 3
call vimtap#Is(@d, 'ffoo-lloquor-ffolio-', 'First three accepted unique replacements extracted via direct context expression')

call vimtest#Quit()
