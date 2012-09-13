" ExtractMatchesToReg.vim: Yank matches from range into a register.
"
" DEPENDENCIES:
"
" Source:
"   Implementation inspired by
"	http://vim.wikia.com/wiki/Copy_the_search_results_into_clipboard
"   Use case inspired from a post by Luc Hermitte at
"	http://www.reddit.com/r/vim/comments/ef9zh/any_better_way_to_yank_all_lines_matching_pattern/

" Copyright: (C) 2010-2012 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"	004	14-Sep-2012	Split off documentation and autoload script.
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
"****D echomsg l:cnt string(sort(keys(l:matchingLines)))
	if a:isNonMatchingLines
	    let l:lineNums = filter(range(a:firstLine, a:lastLine), '! has_key(l:matchingLines, v:val)')
	else
	    let l:lineNums = sort(keys(l:matchingLines))
	endif
	let l:lines = join(map(l:lineNums, 'getline(v:val)'), "\n")
	call setreg(l:register, l:lines, 'V')

	echo printf('%d %s%s yanked', l:cnt, (l:isBlocks ? 'block' : 'line'), (l:cnt == 1 ? '' : 's'))
    endif
endfunction

function! s:ExtractText( startPos, endPos )
"*******************************************************************************
"* PURPOSE:
"   Extract the text between a:startPos and a:endPos from the current buffer.
"* ASSUMPTIONS / PRECONDITIONS:
"   none
"* EFFECTS / POSTCONDITIONS:
"   none
"* INPUTS:
"   a:startPos	    [line,col]
"   a:endPos	    [line,col]
"* RETURN VALUES:
"   string text
"*******************************************************************************
    let [l:line, l:column] = a:startPos
    let [l:endLine, l:endColumn] = a:endPos
    if l:line > l:endLine || (l:line == l:endLine && l:column > l:endColumn)
	return ''
    endif

    let l:text = ''
    while 1
	if l:line == l:endLine
	    let l:text .= matchstr( getline(l:line) . "\n", '\%' . l:column . 'c' . '.*\%' . (l:endColumn + 1) . 'c' )
	    break
	else
	    let l:text .= matchstr( getline(l:line) . "\n", '\%' . l:column . 'c' . '.*' )
	    let l:line += 1
	    let l:column = 1
	endif
    endwhile
    return l:text
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
	    let l:match = s:ExtractText(l:startPos, l:endPos)
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
