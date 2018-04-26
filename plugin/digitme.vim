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

function! s:OpenChannel()
  if !exists('s:channel')
    let s:channel = ch_open("localhost:8763")
  else
    if ch_status(s:channel) != "open"
      let s:channel = ch_open("localhost:8763")
    endif
  endif
endfunction

function! digitme#Ping ()
  if ch_status(s:channel) == "open"
    call ch_sendexpr(s:channel, {'ping': localtime()})
  else
    call s:OpenChannel()
  endif
endfunction

function! digitme#shout ()
  return "Hello World"
endfunction

call s:OpenChannel()
autocmd InsertCharPre * :call digitme#Ping()

let &cpo = s:save_cpo
unlet s:save_cpo
