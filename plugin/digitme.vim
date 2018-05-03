" File: digitme
" Description: A Vim Plugin To Abstract Coding Process
" Last Change:	2018 Apr 25
" Maintainer:	Ke Ding <me@dingkewz.com>
" License:	This file is placed in the public domain.

" channel only available in vim version >= 8.0
if v:version < 800
  finish
endif

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
function! digitme#ping()
  call digitme#send( {'event': 'ping'} )
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

function! digitme#validate( msg )
  if type(a:msg) != v:t_dict
    return v:false
  endif
  if !has_key(a:msg, 'event')
    return v:false
  endif
  if type( a:msg['event'] ) != v:t_string
    return v:false
  endif
  return v:true
endfunction

function! digitme#send( msg )
  let l:isValid = digitme#validate( a:msg )
  if !l:isValid
    return v:false
  endif
  let a:msg['ts'] = localtime()
  if ch_status( s:channel ) == "open"
    call ch_sendexpr( s:channel, a:msg )
    return v:true
  else
    call s:OpenChannel()
    return v:false
  endif
endfunction

call digitme#init()
call s:OpenChannel()
augroup digitme
  autocmd!
  autocmd CursorMoved * :call digitme#ping()
  autocmd CursorMovedI * :call digitme#ping()
augroup END

let &cpo = s:save_cpo
unlet s:save_cpo
