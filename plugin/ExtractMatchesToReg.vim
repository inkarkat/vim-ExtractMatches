" GrepToReg.vim: Yank matches from range into a register. 
"
" DEPENDENCIES:
"
" Copyright: (C) 2010 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'. 
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS 
"	001	09-Dec-2010	file creation

" Avoid installing twice or when in unsupported Vim version. 
if exists('g:loaded_GrepToReg') || (v:version < 700)
    finish
endif
let g:loaded_GrepToReg = 1

function! s:ParsePatternArg( args )
    let l:matches = matchlist(a:args, '\V\^\(\i\@!\.\)\(\.\*\)\1\s\*\(\[a-zA-Z0-9-"*+_/]\)\?\s\*\$')
    if empty(a:args)
	" Corner case: No argument given; use previous search pattern and the
	" unnamed register. 
	let [l:pattern, l:register] = [@/, '']
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

":[range]GrepToReg[!] /{pattern}/[x]
":[range]GrepToReg[!] {pattern}
"			Yank all lines in [range] that match {pattern} (with !:
"			do not match) into register [x] (or the unnamed register). 
function! s:GrepToReg( firstLine, lastLine, args, isNonMatchingLines )
    let l:save_view = winsaveview()

    let [l:pattern, l:register] = s:ParsePatternArg(a:args)

    let l:matchingLines = {}
    let l:cnt = 0
    let l:isBlocks = 0
    let l:startLine = a:firstLine
    while 1
	call cursor(l:startLine, 1)
	let l:startLine = search(l:pattern, 'cnW', a:lastLine)
	if l:startLine == 0 | break | endif
	let l:endLine = search(l:pattern, 'cenW', a:lastLine)
	if l:endLine == 0 || l:endLine > a:lastLine | break | endif 
	for l:line in range(l:startLine, l:endLine)
	    let l:matchingLines[l:line] = 1
	endfor
	let l:cnt += 1
	let l:isBlocks = l:isBlocks || (l:startLine != l:endLine)
	let l:startLine += 1
    endwhile

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
    endif

    call winrestview(l:save_view)

    if l:cnt > 0 && l:cnt > &report
	echo printf('%d %s%s yanked', l:cnt, (l:isBlocks ? 'block' : 'line'), (l:cnt == 1 ? '' : 's'))
    endif
endfunction
command! -bang -nargs=? -range=% GrepToReg call <SID>GrepToReg(<line1>, <line2>, <q-args>, <bang>0)

" vim: set sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
