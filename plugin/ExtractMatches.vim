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

" Copyright: (C) 2010-2018 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>

" Avoid installing twice or when in unsupported Vim version.
if exists('g:loaded_ExtractMatches') || (v:version < 700)
    finish
endif
let g:loaded_ExtractMatches = 1

command! -bang -nargs=? -range=% GrepToReg if ! ExtractMatches#GrepToReg(<line1>, <line2>, <q-args>, <bang>0) | echoerr ingo#err#Get() | endif
command! -bang -nargs=? -range=% GrepRangeToReg if ! ExtractMatches#GrepRangeToReg(<line1>, <line2>, <q-args>, <bang>0) | echoerr ingo#err#Get() | endif

command! -bang -nargs=? -range=% YankMatches       if ! ExtractMatches#YankMatches(<line1>, <line2>, <q-args>, <bang>0, 0) | echoerr ingo#err#Get() | endif
command! -bang -nargs=? -range=% YankUniqueMatches if ! ExtractMatches#YankMatches(<line1>, <line2>, <q-args>, <bang>0, 1) | echoerr ingo#err#Get() | endif

command! -bang -nargs=? -range=% PrintMatches       if ! ExtractMatches#PrintMatches(<line1>, <line2>, <q-args>, <bang>0, 0) | echoerr ingo#err#Get() | endif
command! -bang -nargs=? -range=% PrintUniqueMatches if ! ExtractMatches#PrintMatches(<line1>, <line2>, <q-args>, <bang>0, 1) | echoerr ingo#err#Get() | endif

command!       -nargs=+ -range SubstituteAndYank       call setline(<line1>, getline(<line1>)) | if ! ExtractMatches#SubstituteAndYank(<line1>, <line2>, <q-args>, 0) | echoerr ingo#err#Get() | endif
command!       -nargs=+ -range SubstituteAndYankUnique call setline(<line1>, getline(<line1>)) | if ! ExtractMatches#SubstituteAndYank(<line1>, <line2>, <q-args>, 1) | echoerr ingo#err#Get() | endif

command! -bang -nargs=? -range=-1 PutMatches       call setline(<line1>, getline(<line1>)) | call ExtractMatches#PutMatches(<line2> == 1 ? <line1> : <line2> , <q-args>, <bang>0, 0)
command! -bang -nargs=? -range=-1 PutUniqueMatches call setline(<line1>, getline(<line1>)) | call ExtractMatches#PutMatches(<line2> == 1 ? <line1> : <line2> , <q-args>, <bang>0, 1)

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
