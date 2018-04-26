" File: digitme
" Description: A Vim Plugin To Abstract Coding Process
" Last Change:	2018 Apr 25
" Maintainer:	Ke Ding <me@dingkewz.com>
" License:	This file is placed in the public domain.

" Only load once
if exists("g:loaded_digitme")
  finish
endif
let g:loaded_digitme = 1

let s:save_cpo = &cpo
set cpo&vim

" Default Plugin Options
function! digitme#init()
  let g:hitme#clientUrl = get(g:, 'hitme#clientUrl', "localhost:8763")
endfunction

" Ping Client When Cursor Moved
function! digitme#ping ()
  if ch_status(s:channel) == "open"
    call ch_sendexpr(s:channel, {'ping': localtime()})
  else
    call s:OpenChannel()
  endif
endfunction

function! s:OpenChannel()
  if !exists('s:channel')
    let s:channel = ch_open(g:hitme#clientUrl)
  else
    if ch_status(s:channel) != "open"
      let s:channel = ch_open(g:hitme#clientUrl)
    endif
  endif
endfunction

call digitme#init()
call s:OpenChannel()
autocmd InsertCharPre * :call digitme#ping()

let &cpo = s:save_cpo
unlet s:save_cpo
