" ExtractMatches.vim: Yank matches from range into a register.
"
" DEPENDENCIES:
"   - ingo/cmdargs/pattern.vim autoload script
"   - ingo/cmdargs/range.vim autoload script
"   - ingo/cmdargs/substitute.vim autoload script
"   - ingo/collections.vim autoload script
"   - ingo/err.vim autoload script
"   - ingo/escape.vim autoload script
"   - ingo/range/lines.vim autoload script
"   - ingo/regexp/magic.vim autoload script
"   - ingo/register.vim autoload script
"   - ingo/subst.vim autoload script
"   - ingo/text.vim autoload script
"   - ingo/text/frompattern.vim autoload script
"   - PatternsOnText.vim autoload script (for :SubstituteAndYank)
"
" Copyright: (C) 2010-2017 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"   1.40.027    23-Jan-2017	:YankMatches does not handle magicness modifier
"				atoms (\v, \M, etc.) before / after \zs / \ze.
"				They get cut away, and then the remaining
"				pattern does not match any longer, and a custom
"				{replacement} is not applied. Normalize the
"				magicness in the pattern. Additionally, also
"				keep a case-sensitivity atom (\c, \C).
"   1.40.026	07-Dec-2016	Factor out s:Grep. Handle grabbing not just the
"				current line, but a range context around it.
"				Add ExtractMatches#GrepRangeToReg().
"   1.32.025	17-Oct-2016	In PatternsOnText.vim version 2.0,
"				PatternsOnText#Selected#ReplaceSpecial() has
"				been moved to PatternsOnText#DefaultReplacer().
"   1.31.024	06-Dec-2014	BUG: :GrepToReg runs into endless loop when the
"				last line of the buffer belongs to the range and
"				is matching. This is because positioning one
"				beyond the last line just keeps the cursor at
"				the previous line, and repeats the last match.
"				Shorter ranges are limited by the stopline of
"				search() already. Note: We could limit the while
"				condition to a:lastLnum, but would then have to
"				translate folds ourselves.
"   1.31.023	29-May-2014	Refactoring: Use
"				ingo#cmdargs#pattern#ParseUnescaped().
"   1.30.022	13-Mar-2014	When no replacement has been specified, yank the
"				original matches with trailing newlines.
"				Extract s:JoinMatches().
"				Implement :PrintMatches command.
"   1.30.021	12-Mar-2014	FIX: Inline pasting (with replacements) is
"				broken due to wrong quoting.
"				FIX: Inline pasting (with replacements) doesn't
"				use the specified line and doesn't create a new
"				empty line. In fact, the entire conditional in
"				ExtractMatches#YankAndPaste() isn't necessary.
"				FIX: Typo in variable name prevented elimination
"				of \ze.
"				FIX: Remove escaping of a:replacement to apply
"				the DWIM trailing separator removal also to \\,
"				\n, \t etc.
"				Handle \r, \n, \t, \b in replacement, too.
"				Rename :YankMatchesToReg[Unique] to
"				:YankMatches[Unique], also for
"				ExtractMatches#YankMatchesToReg().
"   1.21.020	10-Mar-2014	Minor refactoring.
"   1.20.019	20-Feb-2014	Add missing escaping of replacement parts in
"				:SubstituteAndYank; as this is done by
"				expressions, the separator character must be
"				unescaped (except for sub-replace-expression,
"				which must not contain the separator character).
"   1.20.018	19-Feb-2014	Switch to ingo/err.vim functions to properly
"				abort the commands on error.
"   1.20.017	18-Feb-2014	Add :SubstituteAndYank[Unique] commands.
"   1.10.016	20-Dec-2013	DWIM: When {replacement} is "&...", assume ...
"				is a (literal) separator and remove it from the
"				last element.
"				Add heuristic that drops \zs, \ze, and all
"				location-aware atoms (like \%v) for the separate
"				substitution for {replacement}, to allow it to
"				match. Beforehand, either nothing or the entire
"				match have been wrongly returned as the result.
"   1.00.015	18-Nov-2013	Use ingo#register#KeepRegisterExecuteOrFunc().
"   1.00.014	03-Sep-2013	Factor out ingo#text#frompattern#Get() to yank
"				into a List without all the user messages.
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

let s:writableRegisterExpr = '\s*\([-a-zA-Z0-9"*+_/]\)\?'

function! s:Grep( firstLnum, lastLnum, isNonMatchingLines, pattern, range, register )
    let l:save_view = winsaveview()
	let l:matchingLines = {}
	let l:cnt = 0
	let l:isBlocks = 0
	let l:didClobberSearchHistory = 0
	let l:startLnum = a:firstLnum
	while l:startLnum <= line('$')
	    call cursor(l:startLnum, 1)
	    let l:startLnum = search(a:pattern, 'cnW', a:lastLnum)
	    if l:startLnum == 0 | break | endif
	    let l:endLnum = search(a:pattern, 'cenW', a:lastLnum)
	    if l:endLnum == 0 | break | endif
	    for l:line in range(l:startLnum, l:endLnum)
		if empty(a:range)
		    let l:matchingLines[l:line] = 1
		else
		    call cursor(l:line, 1)
		    let [l:linesInRange, l:ignoreStartLnums, l:ignoreEndLnums, l:didClobberSearchHistory] = ingo#range#lines#Get(a:firstLnum, a:lastLnum, a:range, 0)
		    call extend(l:matchingLines, l:linesInRange)
		endif
	    endfor
	    let l:cnt += 1
	    let l:isBlocks = l:isBlocks || (l:startLnum != l:endLnum)
	    let l:startLnum += 1
	endwhile
    call winrestview(l:save_view)
    if l:didClobberSearchHistory
	call histdel('search', -1)
    endif

    if l:cnt == 0
	call ingo#err#Set('E486: Pattern not found: ' . (empty(a:pattern) ? @/ : a:pattern))
	return 0
    else
"****D echomsg l:cnt string(sort(keys(l:matchingLines),'ingo#collections#numsort'))
	if a:isNonMatchingLines
	    let l:lineNums = filter(range(a:firstLnum, a:lastLnum), '! has_key(l:matchingLines, v:val)')
	else
	    let l:lineNums = sort(keys(l:matchingLines), 'ingo#collections#numsort')
	endif
	let l:lines = join(map(l:lineNums, 'getline(v:val)'), "\n")
	call setreg(a:register, l:lines, 'V')

	echo printf('%d %s%s yanked', l:cnt, (l:isBlocks ? 'block' : 'line'), (l:cnt == 1 ? '' : 's'))
	return 1
    endif
endfunction
function! ExtractMatches#GrepToReg( firstLnum, lastLnum, arguments, isNonMatchingLines )
    let [l:pattern, l:register] = ingo#cmdargs#pattern#ParseUnescaped(a:arguments, s:writableRegisterExpr)
    let l:register = (empty(l:register) ? '"' : l:register)

    return s:Grep(a:firstLnum, a:lastLnum, a:isNonMatchingLines, l:pattern, '', l:register)
endfunction
function! ExtractMatches#GrepRangeToReg( firstLnum, lastLnum, arguments, isNonMatchingLines )
    let [l:pattern, l:range, l:register] = ingo#cmdargs#pattern#ParseUnescaped(a:arguments, '\s\+\(' . ingo#cmdargs#range#RangeExpr(). '\)\%(\s\+\(' . s:writableRegisterExpr . '\)\)\?', 2)
    if empty(l:range) && ! empty(l:pattern) || l:pattern ==# a:arguments
	" Prefer (mandatory) range over (optional) pattern; it might get parsed incorrectly.
	let l:pattern = ''
	let [l:range, l:register] = ingo#cmdargs#register#ParseAppendedWritableRegister(a:arguments, '[-+,;''[:alnum:][:space:]\\"|]\@![\x00-\xFF]')
    endif
    let l:register = (empty(l:register) ? '"' : l:register)

    if empty(l:range)
	call ingo#err#Set('Wrong syntax: Need to pass {range}')
	return 0
    endif
"****Dechomsg '****' string([l:pattern, l:range, l:register])
    return s:Grep(a:firstLnum, a:lastLnum, a:isNonMatchingLines, l:pattern, l:range, l:register)
endfunction

function! s:SpecialReplacement( pattern, replacement )
    let l:specialAtomExpr = '\%(\%(^\|[^\\]\)\%(\\\\\)*\\\)\@<!\\\%(z[se]\|%[$^V#]\|%[<>]\?[''].\|%[<>]\?\d\+[lcv]\)'
    if ! empty(a:replacement) && a:pattern =~# l:specialAtomExpr
	" As there is no "match in buffer and return substitutions as string"
	" function, the substitution for {replacement} has to be applied
	" separately, on the extracted match. But then, context for {pattern} is
	" lost, and neither location-aware atoms (like /\%v) nor lookahead /
	" lookbehind can be used.

	" To alleviate that problem, we can at least add a heuristic to drop ...\zs
	" and \ze... from the pattern (having fulfilled its limiting condition)
	" for the replacement (which is now done on the sole match).
	" Note: This simplistic rule won't correctly handle the atoms inside
	" branches.
	" Note: Atoms that change the magicness or case sensitivity cannot
	" simply be dropped. We can solve the former by normalizing them out. As
	" the latter globally affect the entire pattern, we need to keep them.
	let l:replacePattern = ingo#regexp#magic#Normalize(a:pattern)
	let l:keepCaseSensitivityAtomPattern = '.*\%(\%(^\|[^\\]\)\%(\\\\\)*\\\)\@<!\(\\[cC]\)'
	" Note: Optional /\?/ matching within the non-greedy /\{-}/ does not
	" always capture; need to attempt matching with, then fall back to
	" matching without the l:keepCaseSensitivityAtomPattern.
	let l:replacePattern = ingo#subst#FirstParameter(l:replacePattern, '^%s.\{-}\%%(\%%(^\|[^\\]\)\%%(\\\\\)*\\\)\@<!\\zs', '\1', '', l:keepCaseSensitivityAtomPattern, '')[1]
	let l:replacePattern = ingo#subst#FirstParameter(l:replacePattern, '\%%(\%%(^\|[^\\]\)\%%(\\\\\)*\\\)\@<!\\ze%s.\{-}$', '\1', '', l:keepCaseSensitivityAtomPattern, '')[1]

	" Also remove any location-aware atoms; it's not guaranteed that this
	" give the expected result, but it's better than disallowing a match in
	" most cases.
	let l:replacePattern = substitute(l:replacePattern, l:specialAtomExpr, '', 'g')

	return [l:replacePattern, a:replacement]
    else
	return a:replacement
    endif
endfunction
function! ExtractMatches#PrintMatches( firstLnum, lastLnum, arguments, isOnlyFirstMatch, isUnique )
    let [l:separator, l:pattern, l:replacement] = ingo#cmdargs#substitute#Parse(a:arguments, {
    \   'flagsExpr': '', 'emptyReplacement': '', 'emptyFlags': ''
    \})
    let l:pattern = ingo#cmdargs#pattern#Unescape([l:separator, l:pattern])
    let l:replacement = ingo#cmdargs#pattern#Unescape([l:separator, l:replacement])
"****D echomsg '****' string(l:pattern) string(l:replacement)

    let l:matches = ingo#text#frompattern#Get(a:firstLnum, a:lastLnum,
    \   l:pattern, s:SpecialReplacement(l:pattern, l:replacement),
    \   a:isOnlyFirstMatch, a:isUnique
    \)

    if len(l:matches) == 0
	call ingo#err#Set('E486: Pattern not found: ' . l:pattern)
	return 0
    else
	if empty(l:replacement)
	    echo join(l:matches, "\n")
	else
	    echo s:JoinMatches(l:matches, l:replacement)
	endif
	return 1
    endif
endfunction
function! ExtractMatches#YankMatches( firstLnum, lastLnum, arguments, isOnlyFirstMatch, isUnique )
    let [l:separator, l:pattern, l:replacement, l:register] = ingo#cmdargs#substitute#Parse(a:arguments, {
    \   'flagsExpr': s:writableRegisterExpr, 'emptyReplacement': '', 'emptyFlags': ''
    \})
    if empty(l:register) && l:replacement =~# '^' . s:writableRegisterExpr . '$'
	" In this command, {replacement} can be omitted; the following is then
	" taken as the register.
	let l:register = matchlist(l:replacement, '\C^' . s:writableRegisterExpr . '$')[1]
	let l:replacement = ''
    endif
    let l:register = (empty(l:register) ? '"' : l:register)
    let l:pattern = ingo#cmdargs#pattern#Unescape([l:separator, l:pattern])
    let l:replacement = ingo#cmdargs#pattern#Unescape([l:separator, l:replacement])
"****D echomsg '****' string(l:pattern) string(l:replacement) string(l:register)

    let l:matches = ingo#text#frompattern#Get(a:firstLnum, a:lastLnum,
    \   l:pattern, s:SpecialReplacement(l:pattern, l:replacement),
    \   a:isOnlyFirstMatch, a:isUnique
    \)

    if len(l:matches) == 0
	call ingo#err#Set('E486: Pattern not found: ' . l:pattern)
	return 0
    else
	call s:PutMatchesToRegister(l:matches, l:replacement, l:register)
	echo printf('%d %smatch%s yanked', len(l:matches), (a:isUnique ? 'unique ' : ''), (len(l:matches) == 1 ? '' : 'es'))
	return 1
    endif
endfunction
function! s:PutMatchesToRegister( matches, replacement, register )
    if empty(a:replacement)
	let l:lines = join(a:matches, "\n")
	call setreg(a:register, l:lines, 'V')
    else
	call setreg(a:register, s:JoinMatches(a:matches, a:replacement))
    endif
endfunction
function! s:JoinMatches( matches, replacement )
    let l:lines = join(a:matches, '')
    if a:replacement =~# '^&.'
	" DWIM: When {replacement} is "&...", assume ... is a (literal)
	" separator and remove it from the last element
	" Note: By not escaping a:replacement, this handles things like \\,
	" \n, \t etc., but isn't completely correct.
	let l:lines = substitute(l:lines, '\V\C' . a:replacement[1:] . '\$', '', '')
    endif
    return l:lines
endfunction

function! ExtractMatches#SubstituteAndYank( firstLnum, lastLnum, arguments, isUnique )
    let [l:separator, s:pattern, l:replacement, l:register] = ingo#cmdargs#substitute#Parse(a:arguments, {
    \   'flagsExpr': s:writableRegisterExpr, 'emptyReplacement': '', 'emptyFlags': ''
    \})
"****D echomsg '****' string([l:separator, s:pattern, l:replacement, l:register])
    if l:register ==# l:separator
	" Correct parser error; the trailing separator belongs to the
	" (re-parsed) replacement; it isn't a register.
	let l:replacement .= l:register
	let l:register = ''
    endif
    try
	let [l:substReplacement, l:substFlags, l:yankReplacement] = matchlist(l:replacement,
	\   '\C^\(.*\)'.'\%(\%(^\|[^\\]\)\%(\\\\\)*\\\)\@<!\V' . l:separator . '\m\(&\?[cegiInp#lr]*\)\V' . l:separator . '\m\(.*\)$'
	\)[1:3]
	let s:substReplacement = (l:substReplacement =~# '^\\=' ? l:substReplacement : ingo#escape#Unescape(l:substReplacement, '\' . l:separator))
	let s:yankReplacement = (l:yankReplacement =~# '^\\=' ? l:yankReplacement : ingo#escape#Unescape(l:yankReplacement, '\' . l:separator))
    catch /^Vim\%((\a\+)\)\=:E688:/ " E688: More targets than List items
	call ingo#err#Set('Wrong syntax; pass /{pattern}/{replacement}/[flags]/{yank-replacement}/[x]')
	return 0
    catch /^Vim\%((\a\+)\)\=:/
	call ingo#err#SetVimException()
	return 0
    catch
	call ingo#err#SetVimException()    " Anything else.
	return 0
    endtry
"****D echomsg '****' string([l:separator, s:pattern, l:replacement, l:register, s:substReplacement, l:substFlags, s:yankReplacement])

    let l:accumulatorMatches = []
    let l:accumulatorReplacements = []
    try
	execute printf('%d,%dsubstitute %s%s%s\=s:Collect(l:accumulatorMatches, l:accumulatorReplacements, %d)%s%s',
	\   a:firstLnum, a:lastLnum, l:separator, s:pattern, l:separator,
	\   a:isUnique, l:separator, l:substFlags
	\)
"****D echomsg '****' string(l:accumulatorReplacements)
	if len(l:accumulatorReplacements) > 0
	    call s:PutMatchesToRegister(l:accumulatorReplacements, s:yankReplacement, l:register)
	    echo printf('%d %smatch%s yanked', len(l:accumulatorReplacements), (a:isUnique ? 'unique ' : ''), (len(l:accumulatorReplacements) == 1 ? '' : 'es'))
	endif
	return 1
    catch /^Vim\%((\a\+)\)\=:/
	call ingo#err#SetVimException()
	return 0
    endtry
endfunction
function! s:ExpandIndexInRepl( replacement, index )
    return substitute(a:replacement, '\%(\%(^\|[^\\]\)\%(\\\\\)*\\\)\@<!\\#', a:index + 1, 'g')
endfunction
function! s:ExpandIndexInExpr( expr, index )
    return substitute(a:expr, '\<v:key\>', a:index, 'g')
endfunction
function! s:Collect( accumulatorMatches, accumulatorReplacements, isUnique )
    let l:match = submatch(0)
    if a:isUnique
	let l:idx = index(a:accumulatorMatches, l:match)
	if l:idx == -1
	    call add(a:accumulatorMatches, l:match)
	    let l:idx = len(a:accumulatorMatches) - 1
	endif
    else
	call add(a:accumulatorMatches, l:match)
	let l:idx = len(a:accumulatorMatches) - 1
    endif

    if len(a:accumulatorReplacements) < l:idx + 1
	" This is a newly added match; need to process the replacement here in
	" order to be able to let sub-replace-expressions have access to
	" context-dependent functions like submatch(), line(), etc.
	call add(a:accumulatorReplacements, s:ReplaceYank(l:match, l:idx))
    endif

    if s:substReplacement =~# '^\\='
	" Handle sub-replace-special.
	return eval(s:ExpandIndexInExpr(s:substReplacement[2:], l:idx))
    else
	" Handle & and \0, \1 .. \9, and \r\n\t\b (but not \u, \U, etc.)
	return PatternsOnText#ReplaceSpecial('', s:ExpandIndexInRepl(s:substReplacement, l:idx), '\%(&\|\\[0-9rnbt]\)', function('PatternsOnText#DefaultReplacer'))
    endif
endfunction
function! s:ReplaceYank( match, idx )
    if empty(s:yankReplacement)
	" When no replacement has been specified, yank the original matches with
	" trailing newlines. This is consistent with :YankMatches/{pat}//, and
	" better than simply returning nothing here, which would yank N-1
	" newlines.
	return a:match
    elseif s:yankReplacement =~# '^\\='
	return eval(s:ExpandIndexInExpr(s:yankReplacement[2:], a:idx))
    else
	let l:replacement = s:SpecialReplacement(s:pattern, s:ExpandIndexInRepl(s:yankReplacement, a:idx))
	if type(l:replacement) == type([])
	    return substitute(a:match, l:replacement[0], l:replacement[1], 'g')
	else
	    return substitute(a:match, (empty(s:pattern) ? @/ : s:pattern), l:replacement, '')
	endif
    endif
endfunction

function! ExtractMatches#PutMatches( lnum, arguments, isOnlyFirstMatch, isUnique )
    call ingo#register#KeepRegisterExecuteOrFunc(
    \   function('ExtractMatches#YankAndPaste'),
    \   'Yank' . (a:isUnique ? 'Unique' : '') . 'Matches' . (a:isOnlyFirstMatch ? '!' : '') . ' ' . a:arguments,
    \   a:lnum
    \)
endfunction
function! ExtractMatches#YankAndPaste( yankCommand, lnum )
    execute a:yankCommand
    execute a:lnum . 'put'
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
