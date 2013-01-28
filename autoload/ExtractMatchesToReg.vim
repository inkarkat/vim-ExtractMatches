" ExtractMatchesToReg.vim: Yank matches from range into a register.
"
" DEPENDENCIES:
"   - ingointegration.vim autoload script
"   - ingocollections.vim autoload script
"
" Copyright: (C) 2010-2013 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"	005	15-Jan-2013	FIX: Need to use numerical sort() on line
"				numbers.
"	004	14-Sep-2012	Split off documentation and autoload script.
"				Reuse ingointegration#GetText() for text
"				extraction; remove duplicated s:ExtractText().
"	003	11-May-2012	FIX: Correct non-identifier pattern to avoid
"				matching surrounding whitespace.
"	002	06-Dec-2011	Add :CopyUniqueMatchesToReg variation.
"				Do not consider &report; in contrast to the
"				built-in Vim commands, the result is
"				indeterministic enough to always warrant a
"				status message.
"				Tighten positioning of winsaveview() /
"				winrestview().
"	001	09-Dec-2010	file creation

function! s:ParsePatternArg( args )
    let l:matches = matchlist(a:args, '\V\^\(\i\@!\S\)\(\.\*\)\1\s\*\(\[a-zA-Z0-9-"*+_/]\)\?\s\*\$')
    if empty(a:args)
	" Corner case: No argument given; use previous search pattern and the
	" unnamed register.
	let [l:pattern, l:register] = ['', '']
    elseif empty(l:matches)
	" No pattern separator and register; use entire argument as pattern and
	" the unnamed register.
	let [l:pattern, l:register] = [a:args, '']
    else
	let [l:pattern, l:register] = l:matches[2:3]
    endif
    let l:register = (empty(l:register) ? '"' : l:register)

    return [l:pattern, l:register]
endfunction

function! ExtractMatchesToReg#GrepToReg( firstLine, lastLine, args, isNonMatchingLines )
    let [l:pattern, l:register] = s:ParsePatternArg(a:args)

    let l:save_view = winsaveview()
	let l:matchingLines = {}
	let l:cnt = 0
	let l:isBlocks = 0
	let l:startLine = a:firstLine
	while 1
	    call cursor(l:startLine, 1)
	    let l:startLine = search(l:pattern, 'cnW', a:lastLine)
	    if l:startLine == 0 | break | endif
	    let l:endLine = search(l:pattern, 'cenW', a:lastLine)
	    if l:endLine == 0 | break | endif
	    for l:line in range(l:startLine, l:endLine)
		let l:matchingLines[l:line] = 1
	    endfor
	    let l:cnt += 1
	    let l:isBlocks = l:isBlocks || (l:startLine != l:endLine)
	    let l:startLine += 1
	endwhile
    call winrestview(l:save_view)

    if l:cnt == 0
	let v:errmsg = 'E486: Pattern not found: ' . l:pattern
	echohl ErrorMsg
	echomsg v:errmsg
	echohl None
    else
"****D echomsg l:cnt string(sort(keys(l:matchingLines),'ingocollections#numsort'))
	if a:isNonMatchingLines
	    let l:lineNums = filter(range(a:firstLine, a:lastLine), '! has_key(l:matchingLines, v:val)')
	else
	    let l:lineNums = sort(keys(l:matchingLines), 'ingocollections#numsort')
	endif
	let l:lines = join(map(l:lineNums, 'getline(v:val)'), "\n")
	call setreg(l:register, l:lines, 'V')

	echo printf('%d %s%s yanked', l:cnt, (l:isBlocks ? 'block' : 'line'), (l:cnt == 1 ? '' : 's'))
    endif
endfunction

function! s:UniqueAdd( list, expr )
    if index(a:list, a:expr) == -1
	call add(a:list, a:expr)
    endif
endfunction
function! ExtractMatchesToReg#CopyMatchesToReg( firstLine, lastLine, args, isOnlyFirstMatch, isUnique )
    let [l:pattern, l:register] = s:ParsePatternArg(a:args)

    let l:save_view = winsaveview()
	let l:matches = []
	call cursor(a:firstLine, 1)
	let l:isFirst = 1
	while 1
	    let l:startPos = searchpos(l:pattern, (l:isFirst ? 'c' : '') . 'W', a:lastLine)
	    let l:isFirst = 0
	    if l:startPos == [0, 0] | break | endif
	    let l:endPos = searchpos(l:pattern, 'ceW', a:lastLine)
	    if l:endPos == [0, 0] | break | endif
	    let l:match = ingointegration#GetText(l:startPos, l:endPos)
	    if a:isUnique
		call s:UniqueAdd(l:matches, l:match)
	    else
		call add(l:matches, l:match)
	    endif
"****D echomsg '****' string(l:startPos) string(l:endPos) string(l:match)
	    if a:isOnlyFirstMatch
		normal! $
	    endif
	endwhile
    call winrestview(l:save_view)

    if len(l:matches) == 0
	let v:errmsg = 'E486: Pattern not found: ' . l:pattern
	echohl ErrorMsg
	echomsg v:errmsg
	echohl None
    else
	let l:lines = join(l:matches, "\n")
	call setreg(l:register, l:lines, 'V')

	echo printf('%d %smatch%s yanked', len(l:matches), (a:isUnique ? 'unique ' : ''), (len(l:matches) == 1 ? '' : 'es'))
    endif
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
