" ExtractMatchesToReg.vim: Yank matches from range into a register.
"
" DEPENDENCIES:
"   - ExtractMatchesToReg.vim autoload script
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

" Avoid installing twice or when in unsupported Vim version.
if exists('g:loaded_ExtractMatchesToReg') || (v:version < 700)
    finish
endif
let g:loaded_ExtractMatchesToReg = 1

command! -bang -nargs=? -range=% GrepToReg call ExtractMatchesToReg#GrepToReg(<line1>, <line2>, <q-args>, <bang>0)

command! -bang -nargs=? -range=% CopyMatchesToReg       call ExtractMatchesToReg#CopyMatchesToReg(<line1>, <line2>, <q-args>, <bang>0, 0)
command! -bang -nargs=? -range=% CopyUniqueMatchesToReg call ExtractMatchesToReg#CopyMatchesToReg(<line1>, <line2>, <q-args>, <bang>0, 1)

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
