" ExtractMatches.vim: Yank matches from range into a register.
"
" DEPENDENCIES:
"   - ingo/msg.vim autoload script
"   - ingo/cmdargs/pattern.vim autoload script
"   - ingo/cmdargs/substitute.vim autoload script
"   - ingo/collections.vim autoload script
"   - ingo/text/.vim autoload script
"
" Copyright: (C) 2010-2013 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"   	013	23-Jul-2013	Move ingointegration#GetText() into
"				ingo-library.
"   	012	14-Jun-2013	Minor: Make matchlist() robust against
"				'ignorecase'.
"	011	01-Jun-2013	Move functions from ingo/cmdargs.vim to
"				ingo/cmdargs/pattern.vim and
"				ingo/cmdargs/substitute.vim.
"   	010	29-May-2013	Adapt to changed
"				ingo#cmdargs#ParseSubstituteArgument() interface
"				in ingo-library version 1.006.
"				Handle the special case of omitted
"				{replacement}, which the parser doesn't support.
"	009	28-May-2013	Rename Copy to Yank; it's the correct Vim
"				terminology and more consistent with :yank.
"	008	21-Feb-2013	Use ingo-library.
"	007	30-Jan-2013	Move :PutMatches from ingocommands.vim here.
"				Make it paste after the cursor when (due to
"				replacement), the register is characterwise.
"	006	29-Jan-2013	Replace s:ParsePatternArg() with
"				ingocmdargs#ParsePatternArgument().
"				ENH: Allow optional /{replacement}/ part for
"				:CopyMatchesToReg.
"				Use ingo#msg#ErrorMsg().
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
let s:save_cpo = &cpo
set cpo&vim

function! ExtractMatches#GrepToReg( firstLine, lastLine, arguments, isNonMatchingLines )
    let [l:pattern, l:register] = ingo#cmdargs#pattern#Unescape(ingo#cmdargs#pattern#Parse(a:arguments, '\s*\([-a-zA-Z0-9"*+_/]\)\?'))
    let l:register = (empty(l:register) ? '"' : l:register)

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
	call ingo#msg#ErrorMsg('E486: Pattern not found: ' . l:pattern)
    else
"****D echomsg l:cnt string(sort(keys(l:matchingLines),'ingo#collections#numsort'))
	if a:isNonMatchingLines
	    let l:lineNums = filter(range(a:firstLine, a:lastLine), '! has_key(l:matchingLines, v:val)')
	else
	    let l:lineNums = sort(keys(l:matchingLines), 'ingo#collections#numsort')
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
function! ExtractMatches#YankMatchesToReg( firstLine, lastLine, arguments, isOnlyFirstMatch, isUnique )
    let l:registerExpr = '\s*\([-a-zA-Z0-9"*+_/]\)\?'
    let [l:separator, l:pattern, l:replacement, l:register] = ingo#cmdargs#substitute#Parse(a:arguments, {
    \   'flagsExpr': l:registerExpr, 'emptyReplacement': '', 'emptyFlags': ''
    \})
    if empty(l:register) && l:replacement =~# '^' . l:registerExpr . '$'
	" In this command, {replacement} can be omitted; the following is then
	" taken as the register.
	let l:register = matchlist(l:replacement, '\C^' . l:registerExpr . '$')[1]
	let l:replacement = ''
    endif
    let l:register = (empty(l:register) ? '"' : l:register)
    let l:pattern = ingo#cmdargs#pattern#Unescape([l:separator, l:pattern])
    let l:replacement = ingo#cmdargs#pattern#Unescape([l:separator, l:replacement])
"****D echomsg '****' string(l:pattern) string(l:replacement) string(l:register)
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
	    let l:match = ingo#text#Get(l:startPos, l:endPos)
	    if ! empty(l:replacement)
		let l:match = substitute(l:match, (empty(l:pattern) ? @/ : l:pattern), l:replacement, '')
	    endif
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
	call ingo#msg#ErrorMsg('E486: Pattern not found: ' . l:pattern)
    else
	if empty(l:replacement)
	    let l:lines = join(l:matches, "\n")
	    call setreg(l:register, l:lines, 'V')
	else
	    let l:lines = join(l:matches, '')
	    call setreg(l:register, l:lines)
	endif

	echo printf('%d %smatch%s yanked', len(l:matches), (a:isUnique ? 'unique ' : ''), (len(l:matches) == 1 ? '' : 'es'))
    endif
endfunction

function! ExtractMatches#PutMatches( lnum, arguments, isOnlyFirstMatch, isUnique )
    let l:save_clipboard = &clipboard
    set clipboard= " Avoid clobbering the selection and clipboard registers.
    let l:save_reg = getreg('"')
    let l:save_regmode = getregtype('"')

    try
	execute 'Yank' . (a:isUnique ? 'Unique' : '') . 'MatchesToReg' . (a:isOnlyFirstMatch ? '!' : '') a:arguments
	if getregtype('"') ==# 'V'
	    execute a:lnum . 'put'
	else
	    execute 'normal! a\<C-r>\<C-o>"\<Esc>'
	endif
    finally
	call setreg('"', l:save_reg, l:save_regmode)
	let &clipboard = l:save_clipboard
    endtry
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
