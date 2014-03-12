" ExtractMatches.vim: Yank matches from range into a register.
"
" DEPENDENCIES:
"   - ExtractMatches.vim autoload script
"   - ingo/err.vim autoload script
"
" Source:
"   Implementation inspired by
"	http://vim.wikia.com/wiki/Copy_the_search_results_into_clipboard
"   Use case inspired from a post by Luc Hermitte at
"	http://www.reddit.com/r/vim/comments/ef9zh/any_better_way_to_yank_all_lines_matching_pattern/

" Copyright: (C) 2010-2014 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"   1.30.008	12-Mar-2014	Rename :YankMatchesToReg[Unique] to
"				:YankMatches[Unique].
"   1.20.007	19-Feb-2014	Switch to ingo/err.vim functions to properly
"				abort the commands on error.
"   1.00.006	28-May-2013	Rename Copy to Yank; it's the correct Vim
"				terminology and more consistent with :yank.
"	005	30-Jan-2013	Move :PutMatches from ingocommands.vim here.
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

" Avoid installing twice or when in unsupported Vim version.
if exists('g:loaded_ExtractMatches') || (v:version < 700)
    finish
endif
let g:loaded_ExtractMatches = 1

command! -bang -nargs=? -range=% GrepToReg if ! ExtractMatches#GrepToReg(<line1>, <line2>, <q-args>, <bang>0) | echoerr ingo#err#Get() | endif

command! -bang -nargs=? -range=% YankMatches       if ! ExtractMatches#YankMatches(<line1>, <line2>, <q-args>, <bang>0, 0) | echoerr ingo#err#Get() | endif
command! -bang -nargs=? -range=% YankUniqueMatches if ! ExtractMatches#YankMatches(<line1>, <line2>, <q-args>, <bang>0, 1) | echoerr ingo#err#Get() | endif

command!       -nargs=+ -range=% SubstituteAndYank       call setline(<line1>, getline(<line1>)) | if ! ExtractMatches#SubstituteAndYank(<line1>, <line2>, <q-args>, 0) | echoerr ingo#err#Get() | endif
command!       -nargs=+ -range=% SubstituteAndYankUnique call setline(<line1>, getline(<line1>)) | if ! ExtractMatches#SubstituteAndYank(<line1>, <line2>, <q-args>, 1) | echoerr ingo#err#Get() | endif

command! -bang -nargs=? -range=-1 PutMatches       call setline(<line1>, getline(<line1>)) | call ExtractMatches#PutMatches(<line2> == 1 ? <line1> : <line2> , <q-args>, <bang>0, 0)
command! -bang -nargs=? -range=-1 PutUniqueMatches call setline(<line1>, getline(<line1>)) | call ExtractMatches#PutMatches(<line2> == 1 ? <line1> : <line2> , <q-args>, <bang>0, 1)

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
